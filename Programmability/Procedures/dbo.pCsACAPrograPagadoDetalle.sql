SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAPrograPagadoDetalle]
as
set nocount on
set ansi_Warnings off

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20200327'

--declare @fecini smalldatetime
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
--set @fecini=@fecha--'20200301'

create table #ptmos (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,codusuario varchar(15))

insert into #ptmos
select distinct codprestamo,codasesor,codoficina,nrodiasatraso,codusuario
from tcscartera with(nolock)
where fecha=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
--and codoficina=@codoficina
union
select codprestamo,ultimoasesor,codoficina,0 nrodiasatraso,codusuario
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecha and cancelacion<=@fecha
union
select codprestamo,ultimoasesor,codoficina,0 nrodiasatraso,codusuario
from tcspadroncarteradet with(nolock)
where pasecastigado>=@fecha and pasecastigado<=@fecha

select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #Pogra
from tcspadronplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo
where p.codprestamo in(select codprestamo from #ptmos)
and p.fechavencimiento>=@fecha+1 and p.fechavencimiento<=@fecha+1
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

truncate table tCsACaPrograPagadoDetalle

insert into tCsACaPrograPagadoDetalle
select @fecha+1 fecha,z.nombre region--,p.codoficina
,o.nomoficina sucursal,cl.nombrecompleto Promotor
,p.codprestamo
,cl.nombrecompleto cliente
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7'
	  when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30'
	  when ca.nrodiasatraso>=31 then '31+' else '' end Atraso

,sum(p.montodevengado) - sum(p.montopagado) - sum(p.montocondonado) saldo
,sum(p.montocondonado) condonado
,count(p.codprestamo) programado_n
,sum(p.montodevengado) programado_s
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) anticipado
, count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) puntual
, count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) atrasado
 
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end)
+ count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end)
+ count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) pagado_n
,sum(p.montopagado) pagado_s
,0 pagado_por
,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) sinpago_n
,sum(p.montodevengado) - sum(case when p.estadocuota='CANCELADO' then p.montopagado else 0 end)-sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) sinpago_s
,0 sinpago_por
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.codprestamo else null end) pagoparcial_n
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) pagoparcial_s
,0 parcial_por
,0 total_n
,0 total_s
,0 total_por
--into tCsACaPrograPagadoDetalle
from #Pogra p
inner join #ptmos ca on ca.codprestamo=p.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
inner join tcspadronclientes cl with(nolock) on ca.codusuario=cl.codusuario
where o.zona not in('ZSC','ZCO')
group by z.nombre
,o.nomoficina
,p.codprestamo
,cl.nombrecompleto
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7'
	  when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30'
	  when ca.nrodiasatraso>=31 then '31+' else '' end

drop table #Pogra
drop table #ptmos
GO