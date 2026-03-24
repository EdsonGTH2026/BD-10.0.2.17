SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAColocacionRenovadoReactivadoRegionvs3] @fecini smalldatetime,@fecfin smalldatetime  
as  
set nocount on  
--declare @fecini smalldatetime  
--declare @fecfin smalldatetime  
--set @fecini='20250101'  
--set @fecfin='20250112'  
   
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion--,a.codprestamo,a.desembolso,a.cancelacion  
into #liqreno  
from tcspadroncarteradet p with(nolock)  
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso  
--and substring(p.codprestamo,5,3) = (case when substring(a.codprestamo,5,3) ='370' then '370' else '170' end)  
where p.desembolso>=@fecini  
and p.desembolso<=@fecfin  
and p.codoficina not in('97','999')  
group by p.codprestamo,p.desembolso,p.codusuario  
having max(a.cancelacion) is not null  
  
select lq.codprestamo,lq.desembolso,lq.codusuario,lq.cancelacion,p.primerasesor,p.ultimoasesor,p.codproducto,p.s2inicio  
into #liqreno2  
from #liqreno lq  
inner join tcspadroncarteradet p on p.codusuario=lq.codusuario and p.cancelacion=lq.cancelacion   
--and p.codproducto=substring(lq.codprestamo,5,3)  
--and substring(lq.codprestamo,5,3)=(case when substring(p.codprestamo,5,3) ='370' then '370' else '170' end)  
  
---- renovaciones automaticas: whatsApp 20250117 ZCCU  
SELECT [codprestamo],[MontoDesembolso]
into #RenovAuto 
FROM [FNMGConsolidado].[dbo].[tCaDesembAutoRenovacion] with(nolock) 
where fechaDesembolso >= @fecini--'20250101' 
and fechaDesembolso <= @fecfin--'20250112'  
  
  
select  
dbo.fdufechaaperiodo(p.desembolso) periodo  
,z.nombre region  
,sum(p.monto) totalmonto  
,count(p.codprestamo) totalnro  
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then   
 --p.monto   
   case when p.tiporeprog<>'RENOV' then p.monto else 0 end  
 else 0 end) renovadomonto  
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then   
    --p.monto  
   case when p.tiporeprog='RENOV' then p.monto else 0 end  
  else 0 end) renovadomontoAnticipa
  
,SUM(Case when isnull(ReW.codprestamo,'0')= '0' then 0 else ReW.MontoDesembolso end)renovadomontoAnticipaAuto
,SUM(Case when isnull(ReW.codprestamo,'0')<>'0' then 0 
		  else (case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then   
				case when p.tiporeprog='RENOV' then p.monto else 0 end  
				else 0 end)end)renovadomontoAnticipaAPP
 
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
  
from tcspadroncarteradet p   with(nolock) 
left outer join #liqreno2 l on l.codprestamo=p.codprestamo  
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina  
inner join tclzona z with(nolock) on z.zona=o.zona  
left outer join tcsempleadosfecha e on e.codusuario=l.ultimoasesor and e.fecha=@fecfin-->huerfano  
left outer join #RenovAuto ReW with(nolock) on ReW.codprestamo=p.codprestamo  
where p.desembolso>=@fecini and p.desembolso<=@fecfin  
and p.codoficina not in('97','999')  
group by dbo.fdufechaaperiodo(p.desembolso),z.nombre  
  
drop table #liqreno  
drop table #liqreno2  
drop table #RenovAuto
GO