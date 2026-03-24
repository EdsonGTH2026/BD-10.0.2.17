SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsACAPrograPagadoPromotor]
as
set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20200322'

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
--set @fecini='20200301'

create table #ptmos (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4))

insert into #ptmos
select distinct codprestamo,codasesor,codoficina
from tcscartera with(nolock)
where fecha=@fecha
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and codoficina not in('97','230','231')
and cartera='ACTIVA' 

--and codoficina='37'
union
select codprestamo,ultimoasesor,codoficina
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecini and cancelacion<=@fecha
--and codoficina='37'
union
select codprestamo,ultimoasesor,codoficina
from tcspadroncarteradet with(nolock)
where pasecastigado>=@fecini and pasecastigado<=@fecha
--and codoficina='37'

select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
into #Pogra
from tcspadronplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo
where p.codprestamo in(select codprestamo from #ptmos)
and p.fechavencimiento>=@fecini and p.fechavencimiento<=@fecha
group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

truncate table tCsACaPrograPagadoPromotor
insert into tCsACaPrograPagadoPromotor
select @fecha fecha,z.nombre region,p.codoficina,o.nomoficina sucursal,cl.nombrecompleto Promotor
,p.codasesor,p.fechavencimiento,count(p.codprestamo) Programados,sum(p.montodevengado) Programado,sum(p.montopagado) Pagado,sum(p.montocondonado) Condonado
,sum(p.montodevengado) - sum(p.montopagado) - sum(p.montocondonado) saldo
,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) 
+ count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) 
+ count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) Pagados
,count(p.codprestamo) - count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) SinPago
,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null then p.codprestamo else null end) PagoParcial
--,count(case when p.estadocuota='CANCELADO' then p.codprestamo else null end) xx
--Into tCsACaPrograPagadoPromotor
from #Pogra p
inner join tcspadronclientes cl with(nolock) on p.codasesor=cl.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
--where p.codoficina=37 and p.fechavencimiento='20200320'
group by z.nombre,p.codoficina,o.nomoficina,p.codasesor,p.fechavencimiento,cl.nombrecompleto

drop table #Pogra

drop table #ptmos

--drop table tCsACaPrograPagadoPromotor
--select * from tCsACaPrograPagadoPromotor where codoficina=37 and fechavencimiento='20200320'



GO