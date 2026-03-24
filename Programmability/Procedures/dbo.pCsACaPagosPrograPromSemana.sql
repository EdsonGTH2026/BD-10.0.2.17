SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaPagosPrograPromSemana]
as
set nocount on
set ansi_Warnings off

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20200412'
--select @fecha
declare @diasemana int
set @diasemana = case when DATEPART(weekday, @fecha)=1 then 6 when DATEPART(weekday, @fecha)=2 then 0 else DATEPART(weekday, @fecha)-2 end
--select @diasemana
--select dateadd(day,(-1)*@diasemana,@fecha)
declare @fecha_plan smalldatetime
set @fecha_plan=dateadd(day,(-1)*@diasemana,@fecha)

create table #ptmos (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int,cuotas int)
insert into #ptmos
select distinct c.codprestamo,c.codasesor,c.codoficina,c.nrodiasatraso,p.secuenciacliente,c.nrocuotas-a.nrocuotas
--select *
from tcscartera c with(nolock)
--where fecha='20200520' and tiporeprog='REEST' and cartera='ACTIVA'
inner join tcspadroncarteradet p with(nolock) on p.codprestamo=c.codprestamo
inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.fechadesembolso
where c.fecha=@fecha
and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
union
select c.codprestamo,c.ultimoasesor,c.codoficina,0 nrodiasatraso,c.secuenciacliente,c.nrocuotas-a.nrocuotas
from tcspadroncarteradet c with(nolock)
inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.desembolso
where c.cancelacion>=@fecha_plan and c.cancelacion<=@fecha
union
select c.codprestamo,c.ultimoasesor,c.codoficina,0 nrodiasatraso,c.secuenciacliente,c.nrocuotas-a.nrocuotas
from tcspadroncarteradet c with(nolock)
inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.desembolso
where c.pasecastigado>=@fecha_plan and c.pasecastigado<=@fecha

select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #Pogra
from tcspadronplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
where --p.fecha=@fecha_plan and 
p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)
and p.fechavencimiento>=@fecha_plan and p.fechavencimiento<=@fecha
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

delete from tCsACaPagosPrograPromSemana where fecha=@fecha

insert into tCsACaPagosPrograPromSemana
select @fecha fecha,p.fechavencimiento,z.nombre region,ca.codoficina,o.nomoficina sucursal
,pro.nombrecompleto Promotor
,count(p.codprestamo) Programado_N
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) Anticipado
,count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) Puntual
,count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Atrasado
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end)
+ count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end)
+ count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Pagado_N
,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) SinPago_N
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.codprestamo else null end) PagoParcial_N
,round(case when count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end)=0 then 0
	else (cast(count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) as decimal(16,2))/cast(count(p.codprestamo) as decimal(16,2)))*100 end,2) PorPagado_N
,sum(p.montodevengado) Programado_S
,sum(p.montopagado) Pagado_S
,round(case when sum(p.montopagado)=0 then 0 else (sum(p.montopagado)/sum(p.montodevengado))*100 end,2) PorPagado_S
--into tCsACaPagosPrograPromSemana
from #Pogra p
inner join #ptmos ca on ca.codprestamo=p.codprestamo
inner join tcspadronclientes pro with(nolock) on p.codasesor=pro.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where o.zona not in('ZSC','ZCO')
group by p.fechavencimiento,z.nombre,ca.codoficina,o.nomoficina
,pro.nombrecompleto

drop table #Pogra
drop table #ptmos

GO