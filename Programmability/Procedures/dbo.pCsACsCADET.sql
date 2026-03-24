SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--exec pCsACsImpagos
--Sucursal, nombre de cliente, codprestamo, días en mora, saldo para poner al corriente, saldo total, promotor, domicilio y teléfono-
CREATE procedure [dbo].[pCsACsCADET]
as
set nocount on

declare @Fec smalldatetime
select @Fec=fechaconsolidacion from vcsfechaconsolidacion

declare @Fecha smalldatetime
select @Fecha=@fec+1

select codprestamo into #ca 
from tcscartera with(nolock)
where fecha=@Fec --and nrodiasatraso>=1
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and codoficina not in('97','230','231','999')
and cartera='ACTIVA'
--and codprestamo in(
--'003-170-06-00-02559',
--'003-170-06-02-02272'
--)

--select count(*) nro from #ca 

select c.codprestamo,c.seccuota,sum(c.montocuota) saldo
into #cuo
from tcspadronplancuotas c with(nolock)
where c.seccuota>0 and c.numeroplan=0
and c.codprestamo in(select codprestamo from #ca with(nolock))
and c.estadocuota<>'CANCELADO'
and c.codconcepto in('CAPI','INTE','IVAIT','SDV','RST','IVART')
group by c.codprestamo,c.seccuota

select x.codprestamo,x.saldo
into #Pro
from (
	select codprestamo,nro,max(saldo) saldo
	from (
		select codprestamo,count(seccuota) nro,saldo
		from #cuo a with(nolock)
		group by codprestamo,saldo
	) a
	group by codprestamo,nro
) x
inner join(
          select codprestamo,max(nro) nro
          from (
                select codprestamo,saldo,count(seccuota) nro
                from #cuo a with(nolock)
                group by codprestamo,saldo
          )b 
		  group by codprestamo
) c on x.nro=c.nro and x.codprestamo=c.codprestamo

--select * from #cuo
--select * from #Pro

drop table #cuo

select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto,c.MontoCuota,            
c.MontoDevengado,c.MontoPagado,c.MontoCondonado,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo,
(case 
	when (FechaVencimiento <= @Fecha) then 'ANTERIOR'
	when (c.FechaInicio <= @Fecha and FechaVencimiento >= @Fecha) then 'VIGENTE'
	when (c.FechaInicio >= @Fecha ) then 'SIGUIENTE'
	else  '' end) as Cuota
into #Saldos
from tcspadronplancuotas c with(nolock)
where c.seccuota>0 and c.numeroplan=0
and c.codprestamo in (select codprestamo from #ca with(nolock))

select codprestamo,sum(monto) monto
into #PagoHoy
from (
	select codprestamo, isnull(sum(Saldo),0) monto
	from #Saldos with(nolock)
	where cuota = 'VIGENTE' and CodConcepto in ('MORA', 'IVACM','INTE', 'IVAIT') and Saldo > 0
	group by codprestamo
	union all
	select codprestamo,isnull(sum(Saldo),0) monto
	from #Saldos with(nolock)
	where cuota = 'VIGENTE'
	and CodConcepto in ('CAPI', 'SDV','SDM')
	and Saldo > 0
	and FechaVencimiento = @Fecha 
	group by codprestamo
	union all
	select codprestamo,isnull(sum(Saldo),0) monto
	from #Saldos with(nolock)
	where cuota <> 'VIGENTE'
	and Saldo > 0
	and FechaVencimiento <= @Fecha
	group by codprestamo
) a
group by codprestamo

drop table #Saldos

create table #cuofecs(codprestamo varchar(19),seccuota int,estadocuota varchar(20),fechavencimiento smalldatetime)
insert into #cuofecs
select codprestamo,seccuota,estadocuota,fechavencimiento
from tcspadronplancuotas with(nolock)
where seccuota>0 and numeroplan=0
and codprestamo in (select codprestamo from #ca with(nolock))

group by codprestamo,seccuota,estadocuota,fechavencimiento

create table #fpv(codprestamo varchar(19),fecha smalldatetime, dia varchar(10))
insert into #fpv
select codprestamo, fecha
,case datepart(weekday,fecha) 
	when 1 then 'Domingo'
	when 2 then 'Lunes'
	when 3 then 'Martes'
	when 4 then 'Miercoles'
	when 5 then 'Jueves'
	when 6 then 'Viernes'
	when 7 then 'Lunes'--'Sabado'
	else 'ND' end dia--'DIA_DE_PAGO'
from (
select codprestamo,min(fechavencimiento) fecha
from #cuofecs with(nolock)
where estadocuota<>'CANCELADO'
group by codprestamo
) a
--18,687

drop table #cuofecs

declare @fecini smalldatetime
set @fecini = dbo.fdufechaaperiodo(@fec) + '01'
create table #Bi(codprestamo varchar(19), nroregistros int)
insert into #Bi
exec [10.0.2.14].finmas.dbo.pCsCABitacoraNroFechas @fecini, @fec

truncate table tCsACACADET

insert into tCsACACADET
select @fecha fecha,c.codoficina,o.nomoficina sucursal,cl.nombrecompleto,c.codprestamo,c.nrodiasatraso,c.estado
,isnull(ph.monto,0) 'SaldoPonerCorriente'
,d.saldocapital
,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden
+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden+d.impuestos+d.cargomora+d.otroscargos saldototal
,co.nombrecompleto promotor
,replace(replace(substring(upper(isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri)),1,100),char(13),''),char(10),'') 'Direccion'
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
,mu.descubigeo 'DirMunicipio'
,es.descubigeo 'DirEstado'
,substring(cl.telefonomovil,1,15) telefonomovil
,substring(isnull(cl.telefonodirfampri,cl.telefonodirnegpri),1,15) telefonocasa
,c.fechadesembolso
,c.fechavencimiento
,c.montodesembolso
,pd.secuenciacliente ciclo
,c.nrocuotas
,c.modalidadplazo
,c.tiporeprog
,fpv.fecha 'F_PROXIMO_CORTE'
,fpv.dia 'DIA_DE_PAGO'
,pro.saldo cuota_programada
--into tCsACACADET
,isnull(bi.nroregistros,0) bi_nroregistros
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pd with(nolock) on pd.fechacorte=d.fecha and pd.codprestamo=d.codprestamo and pd.codusuario=d.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
left outer join #PagoHoy ph with(nolock) on ph.codprestamo=c.codprestamo
inner join #fpv fpv with(nolock) on fpv.codprestamo=c.codprestamo
left outer join #Pro pro with(nolock) on pro.codprestamo=c.codprestamo
left outer join #Bi bi with(nolock) on bi.codprestamo=c.codprestamo
where c.fecha=@Fec--'20190102'
and c.codprestamo in (select codprestamo from #ca with(nolock))
--and c.nrodiasatraso>=1

drop table #PagoHoy
drop table #ca
drop table #fpv
drop table #Pro
drop table #bi
--select * from tCsACACADET

GO