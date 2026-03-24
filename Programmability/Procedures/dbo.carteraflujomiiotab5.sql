SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[carteraflujomiiotab5]
as 

select 
dbo.fdufechaaperiodo(p.desembolso) periodo
,sum(p.monto) as 'colocacion'
,sum(case when ciclo=1 then p.monto else 0 end ) as 'colocacion1'
,sum(case when ciclo=2 then p.monto else 0 end ) as 'colocacion2'
,sum(case when ciclo>=3 and ciclo<=4 then p.monto else 0 end ) as 'colocacion3_4'
,sum(case when ciclo>=5 and ciclo<=6 then p.monto else 0 end ) as 'colocacion5_6'
,sum(case when ciclo>=7 then p.monto else 0 end ) as 'colocacion7'
into #grafanamiio
from tcsgrafanamiio p with(nolock) 
group by dbo.fdufechaaperiodo(p.desembolso) 
order by  dbo.fdufechaaperiodo(p.desembolso) 


select dbo.fdufechaaperiodo(fecha) periodo
,sum( p.interes+p.moratorios2 ) as 'totalinteres'
,sum(case when d.ciclo=1 then p.interes+p.moratorios2 else 0 end) as 'totalinteres1'
,sum(case when d.ciclo=2 then p.interes+p.moratorios2 else 0 end) as 'totalinteres2'
,sum(case when d.ciclo>=3 and d.ciclo<4  then p.interes+p.moratorios2 else 0 end) as 'totalinteres3_4'
,sum(case when d.ciclo>=5 and d.ciclo<6  then p.interes+p.moratorios2 else 0 end) as 'totalinteres5_6'
,sum(case when d.ciclo>=7  then p.interes+p.moratorios2 else 0 end) as 'totalinteres7'
into #tcscobranzamiio
from tcscobranzamiio p with(nolock)
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo 
group by dbo.fdufechaaperiodo(fecha) 
order by  dbo.fdufechaaperiodo(fecha) 



select g.periodo
,colocacion
,totalinteres
,0 as '%int'
,'Total' as 'ciclo'
from #grafanamiio g
inner join #tcscobranzamiio c on c.periodo=g.periodo
union
select g.periodo
,colocacion1
,totalinteres1
,case when isnull(totalinteres,0)=0 then 0 else isnull(totalinteres1,0)*100/totalinteres end as '%int'
,'1' as 'ciclo'
from #grafanamiio g
inner join #tcscobranzamiio c on c.periodo=g.periodo
union
select g.periodo
,colocacion2
,totalinteres2
,case when isnull(totalinteres,0)=0 then 0 else isnull(totalinteres2,0)*100/totalinteres end as '%int'
,'2' as 'ciclo'
from #grafanamiio g
inner join #tcscobranzamiio c on c.periodo=g.periodo
union
select g.periodo
,colocacion3_4
,totalinteres3_4
,case when isnull(totalinteres,0)=0 then 0 else isnull(totalinteres3_4,0)*100/totalinteres end as '%int'
,'3_4' as 'ciclo'
from #grafanamiio g
inner join #tcscobranzamiio c on c.periodo=g.periodo
union
select g.periodo
,colocacion5_6
,totalinteres5_6
,case when isnull(totalinteres,0)=0 then 0 else isnull(totalinteres5_6,0)*100/totalinteres end as '%int'
,'5_6' as 'ciclo'
from #grafanamiio g
inner join #tcscobranzamiio c on c.periodo=g.periodo
union
select g.periodo
,colocacion7
,totalinteres7
,case when isnull(totalinteres,0)=0 then 0 else isnull(totalinteres7,0)*100/totalinteres end as '%int'
,'7' as 'ciclo'
from #grafanamiio g
inner join #tcscobranzamiio c on c.periodo=g.periodo


drop table #grafanamiio
drop table #tcscobranzamiio
GO