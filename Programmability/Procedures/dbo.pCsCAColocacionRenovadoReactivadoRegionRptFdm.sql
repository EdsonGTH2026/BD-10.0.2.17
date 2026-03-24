SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----exec pCsCAColocacionRenovadoReactivadoRegionRpt '20180910'
CREATE procedure [dbo].[pCsCAColocacionRenovadoReactivadoRegionRptFdm] @fecfin smalldatetime
as
declare @fecini smalldatetime
--declare @fecfin smalldatetime

--set @fecfin='20180923'
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'--'20180901'

declare @fecini_t smalldatetime
declare @fecfin_t smalldatetime
set @fecini_t=@fecini
set @fecfin_t=@fecfin

create table #co(
	periodo varchar(50),
	region varchar(100),
	montototal money,
	nrototal	money,
	renovadomonto money,
	renovadonro	money,
	reactivadomonto money,
	reactivadonro	money,
	renovadoActivo	money,
	renovadohuerfano	money,
	renovadoReasignado	money,
	reactivadoActivo	money,
	reactivadohuerfano	money,
	reactivadoReasignado	money
)

declare @nro int
declare @n int
set @nro=3--4
set @n=1

while(@nro+1<>@n)
begin
	--select @fecini_t,@fecfin_t
	insert into #co
	--exec pCsCAColocacionRenovadoReactivado @fecini_t,@fecfin_t
	exec pCsCAColocacionRenovadoReactivadoRegion @fecini_t,@fecfin_t

	set @fecini_t=dateadd(month,-@n,@fecini)
	--set @fecfin_t=dateadd(month,-@n,@fecfin)
	select @fecfin_t=ultimodia from tclperiodo where primerdia<=dateadd(month,-@n,@fecfin) and ultimodia>=dateadd(month,-@n,@fecfin)

	set @n=@n+1
end

select *,montototal-renovadomonto-reactivadomonto nuevo
--,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado
into #cx
from #co

insert into #cx(periodo,region,montototal,renovadomonto,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)
select 'Promedio' Titulo,region,avg(montototal) montototal,avg(renovadomonto) renovadomonto,avg(reactivadomonto) reactivadomonto,avg(nuevo) nuevo
,avg(renovadoActivo) renovadoActivo,avg(renovadohuerfano) renovadohuerfano,avg(renovadoReasignado) renovadoReasignado
,avg(reactivadoActivo) reactivadoActivo,avg(reactivadohuerfano) reactivadohuerfano,avg(reactivadoReasignado) reactivadoReasignado
from #cx
where periodo<>dbo.fdufechaaperiodo(@fecfin)
group by region

insert into #cx(periodo,region,montototal,renovadomonto,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)
select 'diferencia' periodo,a.region
,a.montototal-b.montototal montototal
,a.renovadomonto-b.renovadomonto renovadomonto
,a.reactivadomonto-b.reactivadomonto reactivadomonto
,a.nuevo-b.nuevo nuevo
,a.renovadoActivo-b.renovadoActivo renovadoActivo
,a.renovadohuerfano-b.renovadohuerfano renovadohuerfano
,a.renovadoReasignado-b.renovadoReasignado renovadoReasignado
,a.reactivadoActivo-b.reactivadoActivo reactivadoActivo
,a.reactivadohuerfano-b.reactivadohuerfano reactivadohuerfano
,a.reactivadoReasignado-b.reactivadoReasignado reactivadoReasignado
from #cx a
inner join #cx b on a.region=b.region and b.periodo='promedio'
where a.periodo=dbo.fdufechaaperiodo(@fecfin)

select * from #cx

drop table #co
drop table #cx

--create procedure pCsCAColocacionRenovadoReactivadoRegion @fecini smalldatetime,@fecfin smalldatetime
--as
--set nocount on
----declare @fecini smalldatetime
----declare @fecfin smalldatetime
----set @fecini='20180901'
----set @fecfin='20180910'
 
--select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion--,a.codprestamo,a.desembolso,a.cancelacion
--into #liqreno
--from tcspadroncarteradet p with(nolock)
--left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and substring(p.codprestamo,5,3) = (case when substring(a.codprestamo,5,3) ='370' then '370' else '170' end)
--where p.desembolso>=@fecini
--and p.desembolso<=@fecfin
--and p.codoficina<>'97'
--group by p.codprestamo,p.desembolso,p.codusuario
--having max(a.cancelacion) is not null
 
--select
--dbo.fdufechaaperiodo(p.desembolso) periodo
--,z.nombre region
--,sum(p.monto) totalmonto
--,count(p.codprestamo) totalnro
--,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
--,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
--,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
--,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
--from tcspadroncarteradet p
--left outer join #liqreno l on l.codprestamo=p.codprestamo
--inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
--inner join tclzona z with(nolock) on z.zona=o.zona
--where p.desembolso>=@fecini and p.desembolso<=@fecfin
--and p.codoficina<>'97'
--group by dbo.fdufechaaperiodo(p.desembolso),z.nombre

--drop table #liqreno


--create procedure pCsCAColocacionRenovadoReactivado @fecini smalldatetime,@fecfin smalldatetime
--as
--set nocount on
----declare @fecini smalldatetime
----declare @fecfin smalldatetime
----set @fecini='20180901'
----set @fecfin='20180910'
 
--select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion--,a.codprestamo,a.desembolso,a.cancelacion
--into #liqreno
--from tcspadroncarteradet p with(nolock)
--left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and substring(p.codprestamo,5,3) = (case when substring(a.codprestamo,5,3) ='370' then '370' else '170' end)
--where p.desembolso>=@fecini
--and p.desembolso<=@fecfin
--and p.codoficina<>'97'
--group by p.codprestamo,p.desembolso,p.codusuario
--having max(a.cancelacion) is not null
 
--select
--dbo.fdufechaaperiodo(p.desembolso) periodo
--,sum(p.monto) totalmonto
--,count(p.codprestamo) totalnro
--,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
--,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
--,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
--,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
--from tcspadroncarteradet p
--left outer join #liqreno l on l.codprestamo=p.codprestamo
--where p.desembolso>=@fecini and p.desembolso<=@fecfin
--and p.codoficina<>'97'
--group by dbo.fdufechaaperiodo(p.desembolso)
--order by dbo.fdufechaaperiodo(p.desembolso)

--drop table #liqreno

GO