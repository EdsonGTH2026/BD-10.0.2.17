SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAColocacionRenovadoReactivadoRegion] @fecini smalldatetime,@fecfin smalldatetime
as
set nocount on
--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20180901'
--set @fecfin='20180923'
 
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion--,a.codprestamo,a.desembolso,a.cancelacion
into #liqreno
from tcspadroncarteradet p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and substring(p.codprestamo,5,3) = (case when substring(a.codprestamo,5,3) ='370' then '370' else '170' end)
where p.desembolso>=@fecini
and p.desembolso<=@fecfin
and p.codoficina<>'97'
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

select lq.codprestamo,lq.desembolso,lq.codusuario,lq.cancelacion,p.primerasesor,p.ultimoasesor,p.codproducto,p.s2inicio
into #liqreno2
from #liqreno lq
inner join tcspadroncarteradet p on p.codusuario=lq.codusuario and p.cancelacion=lq.cancelacion 
--and p.codproducto=substring(lq.codprestamo,5,3)
and substring(lq.codprestamo,5,3)=(case when substring(p.codprestamo,5,3) ='370' then '370' else '170' end)

select
dbo.fdufechaaperiodo(p.desembolso) periodo
,z.nombre region
,sum(p.monto) totalmonto
,count(p.codprestamo) totalnro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro

,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) 
	then --p.monto 
		cast((case when (e.codusuario is not null and e.codpuesto=66) and l.primerasesor=l.ultimoasesor then p.monto
		else 0 end) as decimal(16,2))
	else 0 end) renovadoActivo

,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) 
	then --p.monto 
		cast(
		(case when (e.codusuario is null or e.codpuesto<>66) then p.monto
		else 0 end) 
		as decimal(16,2))
	else 0 end) renovadohuerfano

,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) 
	then --p.monto 
		cast(
		(case when l.primerasesor<>l.ultimoasesor and @fecfin>=l.s2inicio then p.monto
		else 0 end) 
		as decimal(16,2))
	else 0 end) renovadoReasignado

,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion)
	then --p.monto 
		cast((case when (e.codusuario is not null and e.codpuesto=66) and l.primerasesor=l.ultimoasesor then p.monto
		else 0 end) as decimal(16,2))
	else 0 end) reactivadoActivo

,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion)
	then --p.monto 
		cast(
		(case when (e.codusuario is null or e.codpuesto<>66) then p.monto
		else 0 end) 
		as decimal(16,2))
	else 0 end) reactivadohuerfano

,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion)
	then --p.monto 
		cast(
		(case when l.primerasesor<>l.ultimoasesor and @fecfin>=l.s2inicio then p.monto
		else 0 end) 
		as decimal(16,2))
	else 0 end) reactivadoReasignado

from tcspadroncarteradet p
left outer join #liqreno2 l on l.codprestamo=p.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
left outer join tcsempleadosfecha e on e.codusuario=l.ultimoasesor and e.fecha=@fecfin-->huerfano
where p.desembolso>=@fecini and p.desembolso<=@fecfin
and p.codoficina<>'97'
group by dbo.fdufechaaperiodo(p.desembolso),z.nombre

drop table #liqreno
drop table #liqreno2
GO