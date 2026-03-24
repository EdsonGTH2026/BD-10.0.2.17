SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----exec pCsACaIngresosxIntDetalle '20181015'
CREATE procedure [dbo].[pCsACaIngresosxIntDetalle] @fecha smalldatetime
as
set nocount on
declare @T1 datetime
declare @T2 datetime

--declare @fecha smalldatetime
--set @fecha='20181015'

declare @fecini smalldatetime
--set @fecini='20180901'
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

set @T1=getdate()
--drop table #tca
create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where (codoficina>100 and codoficina<300) and codoficina not in('97','230','231')

--set @T2=getdate()
--print 'Tiempo 1 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
--set @T1 = getdate()

--drop table #ptmos
create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
--into _CarteraPtmos1217
from tcscartera with(nolock)
where fecha>=@fecini and fecha<=@fecha
and cartera='ACTIVA' 
and codoficina not in('97','230','231')
and estado='VIGENTE'
and codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
--and codprestamo='003-170-06-02-00895'

create table #ptmos2 (codprestamo varchar(25))
insert into #ptmos2
select distinct codprestamo 
--into _CarteraPtmos1217
from tcscartera with(nolock)
where fecha>=@fecini and fecha<=@fecha
and cartera='ACTIVA' 
and codoficina not in('97','230','231')
and estado='VIGENTE'
and codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
and codprestamo in (
					select codprestamo from tcspadroncarteradet p with(nolock)
					where p.cancelacion>=@fecini and p.cancelacion<=@fecha
)
--and codprestamo='003-170-06-02-00895'

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
,sum(case when c.codfondo=20 then (d.interesdevengado+d.moratoriodevengado)*0.3 else d.interesdevengado+d.moratoriodevengado end) montodev
,sum(case when c.codfondo=20 then d.interesdevengado*0.3 else d.interesdevengado end) montodevint
,sum(case when c.codfondo=20 then d.moratoriodevengado*0.3 else d.moratoriodevengado end) montodevmor
,avg(case when c.codfondo=20 then d.saldocapital*0.3 else d.saldocapital end) capital
from tcscarteradet d with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha
where d.fecha>=@fecini and d.fecha<=@fecha
and c.cartera='ACTIVA'
and c.estado='VIGENTE'
and d.codprestamo in (select codprestamo from #ptmos)
group by d.codprestamo,d.codusuario

create table #int (codprestamo varchar(25),montoint money)
insert into #int
select t.codigocuenta,sum(case when c.codfondo<>'20' then (t.montointerestran+t.montoinpetran) else 0 end) 
	+ sum(case when c.codfondo='20' then (t.montointerestran+t.montoinpetran)*0.3 else 0 end) saldo
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
,sum(case when c.codfondo=20 then (d.interesdevengado+d.moratoriodevengado)*0.3 else d.interesdevengado+d.moratoriodevengado end) montodev
,sum(case when c.codfondo=20 then d.interesdevengado*0.3 else d.interesdevengado end) montodevint
,sum(case when c.codfondo=20 then d.moratoriodevengado*0.3 else d.moratoriodevengado end) montodevmor
,avg(case when c.codfondo=20 then d.saldocapital*0.3 else d.saldocapital end) capital
from tcscarteradet d with(nolock)
inner join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha
where d.fecha>=@fecini and d.fecha<=@fecha
and c.cartera='ACTIVA'
and c.estado='VIGENTE'
and d.codprestamo in (select codprestamo from #ptmos2)
group by d.codprestamo,d.codusuario

create table #int2 (codprestamo varchar(25),montoint money)
insert into #int2
select t.codigocuenta,sum(case when c.codfondo<>'20' then (t.montointerestran+t.montoinpetran) else 0 end) 
	+ sum(case when c.codfondo='20' then (t.montointerestran+t.montoinpetran)*0.3 else 0 end) saldo
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
,cast(case when c.codfondo=20 
			 then (isnull(d.saldocapital,0)+isnull(d.interesvigente,0)+isnull(d.interesvencido,0)+isnull(d.moratoriovigente,0)+isnull(d.moratoriovencido,0))*0.3
			 else isnull(d.saldocapital,0)+isnull(d.interesvigente,0)+isnull(d.interesvencido,0)+isnull(d.moratoriovigente,0)+isnull(d.moratoriovencido,0) end as decimal(16,2)) 'saldobalance'
,case when c.codfondo=20 then c.montodesembolso*0.3 else c.montodesembolso end montodesembolso_recursos_propios
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
,case when c.codfondo=20 then c.montodesembolso*0.3 else c.montodesembolso end montodesembolso_recursos_propios
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


drop table #tca
drop table #dv
drop table #ptmos
drop table #dv2
drop table #ptmos2
drop table #int2
drop table #int
GO

GRANT EXECUTE ON [dbo].[pCsACaIngresosxIntDetalle] TO [marista]
GO