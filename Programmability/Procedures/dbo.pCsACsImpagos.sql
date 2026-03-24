SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pCsACsImpagos
--Sucursal, nombre de cliente, codprestamo, días en mora, saldo para poner al corriente, saldo total, promotor, domicilio y teléfono-
CREATE procedure [dbo].[pCsACsImpagos]
as
set nocount on

declare @Fec smalldatetime
select @Fec=fechaconsolidacion from vcsfechaconsolidacion

declare @Fecha smalldatetime
select @Fecha=@fec+1

select codprestamo into #ca 
from tcscartera with(nolock)
where fecha=@Fec and nrodiasatraso>=1 and nrodiasatraso<=7

select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto,c.MontoCuota,            
c.MontoDevengado,c.MontoPagado,c.MontoCondonado,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo
--,(case 
--	when (FechaVencimiento <= @Fecha) then 'ANTERIOR'
--	when (c.FechaInicio <= @Fecha and FechaVencimiento >= @Fecha) then 'VIGENTE'
--	when (c.FechaInicio >= @Fecha ) then 'SIGUIENTE'
--	else  '' end) as Cuota
into #Saldos
from tcspadronplancuotas c with(nolock)
where c.codprestamo in (select codprestamo from #ca)

select codprestamo,sum(monto) monto
into #PagoHoy
from (
	select codprestamo, isnull(sum(Saldo),0) monto
	from #Saldos
	where Saldo > 0 and fechavencimiento<=@fecha
	group by codprestamo
	--select codprestamo, isnull(sum(Saldo),0) monto
	--from #Saldos
	--where cuota = 'VIGENTE' and CodConcepto in ('MORA', 'IVACM','INTE', 'IVAIT') and Saldo > 0
	--group by codprestamo
	--union all
	--select codprestamo,isnull(sum(Saldo),0) monto
	--from #Saldos
	--where cuota = 'VIGENTE'
	--and CodConcepto in ('CAPI', 'SDV','SDM')
	--and Saldo > 0
	--and FechaVencimiento = @Fecha 
	--group by codprestamo
	--union all
	--select codprestamo,isnull(sum(Saldo),0) monto
	--from #Saldos
	--where cuota <> 'VIGENTE'
	--and Saldo > 0
	--and FechaVencimiento <= @Fecha
	--group by codprestamo
) a
group by codprestamo

drop table #Saldos

truncate table tCsACAImpagos

--if(datepart(dw,@fecha) in(3,5)) --martes y jueves
--begin
	insert into tCsACAImpagos
	select @fecha fecha,c.codoficina,o.nomoficina sucursal,cl.nombrecompleto,c.codprestamo,c.nrodiasatraso
	,ph.monto 'SaldoPonerCorriente'
	,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden
	+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden+d.impuestos+d.cargomora+d.otroscargos saldototal
	,co.nombrecompleto promotor
	,substring(upper(isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri)),1,100) 'Direccion'
	,substring(case when cl.NumExtFam is null or rtrim(ltrim(cl.NumExtFam))=''
		  then (case when cl.NumExtNeg is null or ltrim(rtrim(cl.NumExtNeg))='' or ltrim(rtrim(cl.NumExtNeg))='sn'
					 then 'S/N' else replace(replace(replace(replace(replace(cl.NumExtNeg,' ',''),'*',''),'-',''),'.',''),'_','') end)
		  when rtrim(ltrim(cl.NumExtFam))='sn' or rtrim(ltrim(cl.NumExtFam))='SINNUMERO' then 'S/N'
		  else replace(replace(replace(replace(replace(cl.NumExtFam,' ',''),'*',''),'-',''),'.',''),'_','') end + ' ' +
	case when cl.NumIntFam is null or rtrim(ltrim(cl.NumIntFam))=''
		  then (case when cl.NumIntNeg is null or ltrim(rtrim(cl.NumIntNeg))='' or ltrim(rtrim(cl.NumIntNeg))='sn'
					 then '' else replace(replace(replace(replace(replace(cl.NumIntNeg,' ',''),'*',''),'-',''),'.',''),'_','') end)
		  when rtrim(ltrim(cl.NumIntFam))='sn' or rtrim(ltrim(cl.NumIntFam))='SINNUMERO' then ''
		  else replace(replace(replace(replace(replace(cl.NumIntFam,' ',''),'*',''),'-',''),'.',''),'_','') end	  
		  ,1,10) 'N° Ext.'--18
	,u.descubigeo 'Colonia'
	,case when isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='' or isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='0'
			then ''
			else isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1) end 'CodPostal'
	,mu.descubigeo 'Municipio'
	,es.descubigeo 'Estado'
	,substring(cl.telefonomovil,1,15) telefonomovil
	,substring(isnull(cl.telefonodirfampri,cl.telefonodirnegpri),1,15) telefonocasa
	,case datepart(weekday,dia.fechavencimiento) 
				when 1 then 'Domingo' 
				when 2 then 'Lunes' 
				when 3 then 'Martes' 
				when 4 then 'Miercoles' 
				when 5 then 'Jueves' 
				when 6 then 'Viernes' 
				when 7 then 'Sabado' 
				end dia
	--,dia.fechavencimiento
	--into tCsACAInpagos_2
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
	inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
	left outer join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
	left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
	left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
	left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
	left outer join #PagoHoy ph on ph.codprestamo=c.codprestamo
	left outer join (
		select codprestamo,fechavencimiento from tcspadronplancuotas with(nolock) where seccuota=1 group by codprestamo,fechavencimiento
	) dia on dia.codprestamo=c.codprestamo
	where c.fecha=@Fec--'20190102'
	and c.nrodiasatraso>=1 and c.nrodiasatraso<=7
--end

drop table #PagoHoy
drop table #ca

--select * from tCsACAImpagos
GO