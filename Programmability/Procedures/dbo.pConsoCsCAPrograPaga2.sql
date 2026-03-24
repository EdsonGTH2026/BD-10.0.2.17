SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pConsoCsCAPrograPaga2] @fecha smalldatetime
as
set nocount on
set ansi_warnings off

--declare @fecha smalldatetime
----select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20200327'

declare @fecini smalldatetime
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecini=@fecha--'20200301'

create table #ptmos (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,cartera varchar(10), ciclo int,codproducto char(3))

insert into #ptmos
select distinct c.codprestamo,c.codasesor,c.codoficina,c.nrodiasatraso,c.estado,d.secuenciacliente,c.codproducto
from tcscartera c with(nolock)
inner join tcspadroncarteradet d with(nolock) on d.codprestamo=c.codprestamo
where c.fecha=@fecha
and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
union
select codprestamo,ultimoasesor,codoficina,0 nrodiasatraso,'LIQUIDADO',secuenciacliente,codproducto
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecini and cancelacion<=@fecha
union
select codprestamo,ultimoasesor,codoficina,0 nrodiasatraso,'CASTIGADO',secuenciacliente,codproducto
from tcspadroncarteradet with(nolock)
where pasecastigado>=@fecini and pasecastigado<=@fecha

select p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #Pogra
from tcsplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo
where p.fecha=@fecha and p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)
and p.fechavencimiento>=@fecini and p.fechavencimiento<=@fecha
group by p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

delete from tCsCaCobPrograPaga where fecha=@fecha
insert into tCsCaCobPrograPaga
select @fecha fecha,z.nombre region,ca.codoficina,o.nomoficina sucursal,ca.cartera,ca.codasesor
,ca.nrodiasatraso,ca.ciclo,ca.codproducto
,sum(p.montocondonado) Condonado
,sum(p.montopagado) Pagado
,sum(p.montodevengado) - sum(p.montopagado) - sum(p.montocondonado) saldo

,count(p.codprestamo) Programado_N
,sum(p.montodevengado) Programado_S

,sum(case when p.estadocuota='CANCELADO' then p.montopagado else 0 end) Pagado_S
,sum(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) Pa_S_Anti
,sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) Pa_S_Punt
,sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) Pa_S_Atra

,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) 
+ count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) 
+ count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Pagado_N
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) Pa_N_Anti
,count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) Pa_N_Punt
,count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Pa_N_Atra

,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) SinPago_N
,sum(p.montodevengado) - sum(case when p.estadocuota='CANCELADO' then p.montopagado else 0 end) 
	- sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) SinPago_S

,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.codprestamo else null end) PagoParcial_N
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago<p.fechavencimiento then p.codprestamo else null end) Par_N_Anti
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago=p.fechavencimiento then p.codprestamo else null end) Par_N_Punt
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Par_N_Atra

,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.montopagado else 0 end) PagoParcial_S
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) Par_S_Anti
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) Par_S_Punt
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) Par_S_Atra
,sum(case when p.estadocuota<>'CANCELADO' and p.fechapago is null then p.montopagado else 0 end) Par_S_ND
from #Pogra p
inner join #ptmos ca on ca.codprestamo=p.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=ca.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where o.zona not in('ZSC','ZCO')
group by z.nombre,ca.codoficina,o.nomoficina,ca.cartera,ca.codasesor
,ca.nrodiasatraso,ca.ciclo,ca.codproducto

drop table #Pogra
drop table #ptmos
GO

GRANT EXECUTE ON [dbo].[pConsoCsCAPrograPaga2] TO [jarriagaa]
GO