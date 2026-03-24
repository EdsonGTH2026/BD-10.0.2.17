SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsADatosCliCarteraCastigada]
as
set nocount on
declare @fecha smalldatetime
--set @fecha='20180930'
select @fecha = fechaconsolidacion from vCsFechaconsolidacion

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo from tcscartera with(nolock)
where fecha=@fecha 
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina not in('97','230','231')
and cartera='CASTIGADA'


select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto
,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo
into #Saldos
from tcspadronplancuotas c with(nolock)
where c.codprestamo in (select codprestamo from #ptmos)

--select * from #Saldos
select codprestamo,sum(monto) monto
into #PagoHoy
from (
	select codprestamo, isnull(sum(Saldo),0) monto
	from #Saldos
	where fechavencimiento<=@Fecha+1--'20190411'
	group by codprestamo
) a
group by codprestamo

select c.CodPrestamo,sum(c.Montocuota) Montocuota
into #MoAmor
from tcspadronplancuotas c with(nolock)
where c.seccuota=1 and c.codprestamo in (select codprestamo from #ptmos)
group by c.CodPrestamo

select c.CodPrestamo
,count(distinct (case when c.FechaVencimiento<=@Fecha+1 then seccuota else null end)) vencidas
into #Cuo
from tcspadronplancuotas c with(nolock)
where c.codprestamo in (select codprestamo from #ptmos)
and c.estadocuota<>'CANCELADO'
group by c.CodPrestamo

create table #cuofecs(codprestamo varchar(19),seccuota int,estadocuota varchar(20),fechavencimiento smalldatetime)
insert into #cuofecs
select codprestamo,seccuota,estadocuota,fechavencimiento
from tcspadronplancuotas with(nolock)
where seccuota>0 and numeroplan=0
and codprestamo in (select codprestamo from #ptmos)
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

declare @fecini smalldatetime
set @fecini = dbo.fdufechaaperiodo(@fecha) + '01'
create table #Bi(codprestamo varchar(19), nroregistros int)
insert into #Bi
exec [10.0.2.14].finmas.dbo.pCsCABitacoraNroFechas @fecini, @fecha

truncate table tCsADatosCliCarteraCastigada

insert into tCsADatosCliCarteraCastigada
SELECT @fecha fecha,c.codprestamo,d.codusuario,cl.nombrecompleto 'NombreCliente',c.codoficina,o.nomoficina sucursal,c.codproducto
,dbo.fduFechaATexto(c.fechadesembolso,'DD/MM/')+cast(year(c.fechadesembolso) as varchar(4)) 'FechaOtorgamiento'
,dbo.fduFechaATexto(c.fechavencimiento,'DD/MM/')+cast(year(c.fechavencimiento) as varchar(4)) 'FechaVencimiento'
,case when c.codfondo=20 
	then (d.montodesembolso)*0.3
	else d.montodesembolso end 'MontoDesembolsoFondeador'
,d.montodesembolso 'MontoDesembolsoTotal'
,c.estado estadocredito
,c.nrodiasatraso
,c.codfondo
,d.saldocapital,d.interesvigente,d.interesvencido,interesctaorden,d.moratoriovigente,d.moratoriovencido,d.moratorioctaorden
,d.cargomora,d.otroscargos,d.impuestos
,co.nombrecompleto nombre_coordinador
,ve.nombrecompleto nombre_verificador
,c.tasaintcorriente 'TasaIntCorriente'
,c.nrocuotas,m.Descripcion 'Frecuencia'
,datediff(day,c.fechadesembolso,c.fechavencimiento) 'PlazoCredito'
--,c.proximovencimiento
,fpv.fecha proximovencimiento
,cl.telefonomovil
,cl.sexo genero
,substring(upper(isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri)),1,100) 'Direccion'
,case when cl.NumExtFam is null or rtrim(ltrim(cl.NumExtFam))=''
	  then (case when cl.NumExtNeg is null or ltrim(rtrim(cl.NumExtNeg))='' or ltrim(rtrim(cl.NumExtNeg))='sn'
				 then 'S/N' else replace(replace(replace(replace(replace(cl.NumExtNeg,' ',''),'*',''),'-',''),'.',''),'_','') end)
	  when rtrim(ltrim(cl.NumExtFam))='sn' or rtrim(ltrim(cl.NumExtFam))='SINNUMERO' then 'S/N'
	  else replace(replace(replace(replace(replace(cl.NumExtFam,' ',''),'*',''),'-',''),'.',''),'_','') end + ' ' +
case when cl.NumIntFam is null or rtrim(ltrim(cl.NumIntFam))=''
	  then (case when cl.NumIntNeg is null or ltrim(rtrim(cl.NumIntNeg))='' or ltrim(rtrim(cl.NumIntNeg))='sn'
				 then '' else replace(replace(replace(replace(replace(cl.NumIntNeg,' ',''),'*',''),'-',''),'.',''),'_','') end)
	  when rtrim(ltrim(cl.NumIntFam))='sn' or rtrim(ltrim(cl.NumIntFam))='SINNUMERO' then ''
	  else replace(replace(replace(replace(replace(cl.NumIntFam,' ',''),'*',''),'-',''),'.',''),'_','') end	  
	   'NUMERO'
,u.descubigeo 'COLONIA'-- DEL ACREDITADO
,case when isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='' or isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='0'
		then ''
		else isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1) end 'CodPostal'-- DEL ACREDITADO
,mu.descubigeo 'MUNICIPIO'
,es.descubigeo 'ESTADO'
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else 'ACTIVO' end coordinadorEstado
,isnull(ph.monto,0) 'SaldoPonerCorriente'
,pcd.secuenciacliente,cl.fechanacimiento,datediff(year,cl.fechanacimiento,@fecha) edad
,c.fechaultimomovimiento
,c.nrocuotaspagadas
--•	Monto ultimo pago
,cuo.vencidas cuotasvencidas--•	Nro de cuotas vencidas
,c.nrocuotasporpagar-cuo.vencidas cuotasxvencer --•	Nro de cuotas por vencer
,ma.montocuota 'montoamortiza'--•	Monto de amortización
--select top 10 * from tCsCartera c with(nolock)
,c.tiporeprog
,fpv.dia 'DIA_DE_PAGO'
,isnull(bi.nroregistros,0) bi_nroregistros
,dc.DescDestino destino
--,c.coddestino
FROM tCsCartera c with(nolock)
inner join tCsCarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pcd with(nolock) on pcd.codprestamo=d.codprestamo and pcd.codusuario=d.codusuario
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=d.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
inner join tcaproducto p with(nolock) on p.codproducto=c.codproducto
left outer join tCaClModalidadPlazo m with(nolock) on m.ModalidadPlazo=c.ModalidadPlazo
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
left outer join tUsClTipoPersona tp with(nolock) on tp.CodTPersona=cl.CodTPersona
left outer join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
left outer join tcspadronclientes ve with(nolock) on ve.codusuario=pcd.CodVerificador
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha
left outer join #PagoHoy ph on ph.codprestamo=c.codprestamo
inner join #MoAmor ma on ma.codprestamo=c.codprestamo
left outer join #Cuo cuo on cuo.codprestamo=c.codprestamo
inner join #fpv fpv with(nolock) on fpv.codprestamo=c.codprestamo
left outer join #Bi bi with(nolock) on bi.codprestamo=c.codprestamo
left outer join tCaClDestino dc with(nolock) on dc.coddestino=c.coddestino
where c.fecha=@fecha
and c.codprestamo in(select codprestamo from #ptmos)

drop table #ptmos
drop table #Saldos
drop table #PagoHoy
drop table #MoAmor
drop table #Cuo
drop table #cuofecs
drop table #fpv
drop table #Bi


GO