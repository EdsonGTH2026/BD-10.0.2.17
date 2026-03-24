SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaIngresosxIntDetalleTotales] @fecha smalldatetime
as
set nocount on
--declare @T1 datetime
--declare @T2 datetime

--declare @fecha smalldatetime
--set @fecha='20181231'

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

--set @T2=getdate()
--print 'Tiempo 1 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
--set @T1 = getdate()

--drop table #ptmos
create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha>=@fecini and fecha<=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and estado='VIGENTE'
and codprestamo not in (select codprestamo from tCsCarteraAlta)

create table #ptmos2 (codprestamo varchar(25))
insert into #ptmos2
select distinct codprestamo 
from tcscartera with(nolock)
where fecha>=@fecini and fecha<=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and estado='VIGENTE'
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codprestamo in (
					select codprestamo from tcspadroncarteradet p with(nolock)
					where p.cancelacion>=@fecini and p.cancelacion<=@fecha
)

--set @T2=getdate()
--print 'Tiempo 2 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
--set @T1 = getdate()

--drop table #dv
create table #dv(
	codprestamo varchar(25),
	codusuario varchar(15),
	montodev money,
	montodevint money,
	montodevmor money,
	capital money
)
insert into #dv
select d.codprestamo,d.codusuario
,sum(d.interesdevengado+d.moratoriodevengado) montodev
,sum(d.interesdevengado) montodevint
,sum(d.moratoriodevengado) montodevmor
,avg(d.saldocapital) capital
from tcscarteradet d with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha
where d.fecha>=@fecini and d.fecha<=@fecha
and c.cartera='ACTIVA'
and c.estado='VIGENTE'
and d.codprestamo in (select codprestamo from #ptmos)
group by d.codprestamo,d.codusuario

create table #int (codprestamo varchar(25),montoint money)
insert into #int
select t.codigocuenta
,sum(t.montointerestran+t.montoinpetran) saldo
from tcstransacciondiaria t with(nolock)
inner join (select codprestamo, fechacorte 
			from tcspadroncarteradet with(nolock)
			group by codprestamo, fechacorte
			) p on p.codprestamo=t.codigocuenta
inner join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=p.fechacorte
where t.fecha>=@fecini and t.fecha<=@fecha
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codigocuenta in(select codprestamo from #ptmos)
group by t.codigocuenta

create table #dv2(
	codprestamo varchar(25),
	codusuario varchar(15),
	montodev money,
	montodevint money,
	montodevmor money,
	capital money
)
insert into #dv2
select d.codprestamo,d.codusuario
,sum(d.interesdevengado+d.moratoriodevengado) montodev
,sum(d.interesdevengado) montodevint
,sum(d.moratoriodevengado) montodevmor
,avg(d.saldocapital) capital
from tcscarteradet d with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha
where d.fecha>=@fecini and d.fecha<=@fecha
and c.cartera='ACTIVA'
and c.estado='VIGENTE'
and d.codprestamo in (select codprestamo from #ptmos2)
group by d.codprestamo,d.codusuario

create table #int2 (codprestamo varchar(25),montoint money)
insert into #int2
select t.codigocuenta,sum(t.montointerestran+t.montoinpetran) saldo
from tcstransacciondiaria t with(nolock)
inner join (select codprestamo, fechacorte 
			from tcspadroncarteradet with(nolock)
			group by codprestamo, fechacorte
			) p on p.codprestamo=t.codigocuenta
inner join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=p.fechacorte
where t.fecha>=@fecini and t.fecha<=@fecha
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codigocuenta in(select codprestamo from #ptmos)
group by t.codigocuenta

--set @T2=getdate()
--print 'Tiempo 3 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
--set @T1 = getdate()

SELECT 'ACTIVA' Cartera,@fecha fecha,c.codprestamo,rtrim(ltrim(d.codusuario)) codusuario--cl.usrfc,
,cast(isnull(d.saldocapital,0)+isnull(d.interesvigente,0)+isnull(d.interesvencido,0)+isnull(d.moratoriovigente,0)+isnull(d.moratoriovencido,0) as decimal(16,2)) 'saldobalance'
,c.montodesembolso montodesembolso_recursos_propios
,c.montodesembolso montodesembolsoreal
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
,dv.montodev,isnull(i.montoint,0) intefectivos
,c.tasaintcorriente
FROM tCsCartera c with(nolock)
inner join tCsCarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
--inner join tcspadroncarteradet pcd with(nolock) on pcd.codprestamo=d.codprestamo and pcd.codusuario=d.codusuario
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=c.fecha-->huerfano
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
inner join #dv dv on dv.codprestamo=d.codprestamo and dv.codusuario=d.codusuario
left outer join #int i on i.codprestamo=c.codprestamo
where c.fecha=@fecha 
and c.codprestamo in(select codprestamo from #ptmos)

----set @T2=getdate()
----print 'Tiempo 4 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
----set @T1 = getdate()

SELECT 'LIQUIDADOS' Cartera,@fecha fecha,c.codprestamo,rtrim(ltrim(d.codusuario)) codusuario--cl.usrfc,
,0 'saldobalance'
,c.montodesembolso montodesembolso_recursos_propios
,c.montodesembolso montodesembolsoreal
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
,dv.montodev,isnull(i.montoint,0) intefectivos
,c.tasaintcorriente
FROM tcspadroncarteradet pcd with(nolock)
inner join tCsCarteradet d with(nolock) on pcd.codprestamo=d.codprestamo and pcd.codusuario=d.codusuario and pcd.fechacorte=d.fecha
inner join tCsCartera c with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=c.fecha-->huerfano
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
inner join #dv2 dv on dv.codprestamo=d.codprestamo and dv.codusuario=d.codusuario
left outer join #int2 i on i.codprestamo=c.codprestamo
where c.codprestamo in(select codprestamo from #ptmos2)

--set @T2=getdate()
--print 'Tiempo 4 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
--set @T1 = getdate()

drop table #dv
drop table #ptmos
drop table #dv2
drop table #ptmos2
drop table #int2
drop table #int

GO

GRANT EXECUTE ON [dbo].[pCsACaIngresosxIntDetalleTotales] TO [marista]
GO