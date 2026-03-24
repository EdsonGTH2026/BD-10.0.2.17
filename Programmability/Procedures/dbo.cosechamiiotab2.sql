SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[cosechamiiotab2] as  

select dbo.fdufechaaperiodo(t.desembolso) periodo  
,sum(case when  t.NroDiasAtraso > 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3'  
,sum(case when  t.NroDiasAtraso > 3 then 1 else 0 end ) as 'nrocermay3'  
into #carteraactivamiio  
from carteraactivamiio  t with(nolock)  
where dbo.fdufechaaperiodo(t.desembolso)>='202210'  
group by dbo.fdufechaaperiodo(t.desembolso)   
order by  dbo.fdufechaaperiodo(t.desembolso)   
  
select dbo.fdufechaaperiodo(t.desembolso) periodo  
,sum(case when  t.NroDiasAtraso > 3  and  d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c1'  
,sum(case when  t.NroDiasAtraso > 3 and  d.ciclo=1  then 1 else 0 end ) as 'nrocermay3c1'  
,sum(case when  t.NroDiasAtraso > 3  and  d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c2'  
,sum(case when  t.NroDiasAtraso > 3 and  d.ciclo=2  then 1 else 0 end ) as 'nrocermay3c2'  
,sum(case when  t.NroDiasAtraso > 3  and  d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c3_4'  
,sum(case when  t.NroDiasAtraso > 3 and  d.ciclo>=3 and d.ciclo<=4 then 1 else 0 end ) as 'nrocermay3c3_4'  
,sum(case when  t.NroDiasAtraso > 3  and  d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c5_6'  
,sum(case when  t.NroDiasAtraso > 3 and  d.ciclo>=5 and d.ciclo<=6 then 1 else 0 end ) as 'nrocermay3c5_6'  
,sum(case when  t.NroDiasAtraso > 3  and  d.ciclo>=7  then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c7'  
,sum(case when  t.NroDiasAtraso > 3 and  d.ciclo>=7  then 1 else 0 end ) as 'nrocermay3c7'  
into #carteraactivamiiociclos  
from carteraactivamiio  t with(nolock)  
left outer join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo  
where dbo.fdufechaaperiodo(t.desembolso)>='202210'  
group by dbo.fdufechaaperiodo(t.desembolso)   
order by  dbo.fdufechaaperiodo(t.desembolso)   
  
  
select a.periodo  
,cermay3c1  
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3c1,0)*100/cermay3 end as '%monto'  
,nrocermay3c1  
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3c1,0) as money)*100/nrocermay3 end as '%nro'  
,'1' as 'ciclo'  
from  #carteraactivamiio a  
inner join  #carteraactivamiiociclos c on c.periodo=a.periodo  
union  
select a.periodo  
,cermay3c2
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3c2,0)*100/cermay3 end as '%monto'  
,nrocermay3c2
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3c2,0) as money)*100/nrocermay3 end as '%nro'  
,'2' as 'ciclo'  
from  #carteraactivamiio a  
inner join  #carteraactivamiiociclos c on c.periodo=a.periodo  
union  
select a.periodo  
,cermay3c3_4
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3c3_4,0)*100/cermay3 end as '%monto'  
,nrocermay3c3_4
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3c3_4,0) as money)*100/nrocermay3 end as '%nro'  
,'3_4' as 'ciclo'  
from  #carteraactivamiio a  
inner join  #carteraactivamiiociclos c on c.periodo=a.periodo  
union  
select a.periodo  
,cermay3c3_4
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3c3_4,0)*100/cermay3 end as '%monto'  
,nrocermay3c3_4
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3c3_4,0) as money)*100/nrocermay3 end as '%nro'  
,'3_4' as 'ciclo'  
from  #carteraactivamiio a  
inner join  #carteraactivamiiociclos c on c.periodo=a.periodo  
union  
select a.periodo  
,cermay3c5_6
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3c5_6,0)*100/cermay3 end as '%monto'  
,nrocermay3c5_6
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3c5_6,0) as money)*100/nrocermay3 end as '%nro'  
,'5_6' as 'ciclo'  
from  #carteraactivamiio a  
inner join  #carteraactivamiiociclos c on c.periodo=a.periodo  
union  
select a.periodo  
,cermay3c7
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3c7,0)*100/cermay3 end as '%monto'  
,nrocermay3c7
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3c7,0) as money)*100/nrocermay3 end as '%nro'  
,'7' as 'ciclo'  
from  #carteraactivamiio a  
inner join  #carteraactivamiiociclos c on c.periodo=a.periodo  

drop table #carteraactivamiio  
drop table #carteraactivamiiociclos
GO