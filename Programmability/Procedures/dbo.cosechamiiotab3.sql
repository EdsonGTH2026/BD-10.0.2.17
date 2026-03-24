SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext cosechamiiotab3

CREATE procedure [dbo].[cosechamiiotab3] as   
  
select  dbo.fdufechaaperiodo(p.desembolso) periodo    
,sum(p.monto) as 'colocacion'    
,sum(case when ciclo=1 then p.monto else 0 end) as 'colocacionc1'    
,sum(case when ciclo=2 then p.monto else 0 end) as 'colocacionc2'    
into #grafanamiio    
from tcsgrafanamiio p with(nolock)     
group by dbo.fdufechaaperiodo(p.desembolso)     
order by  dbo.fdufechaaperiodo(p.desembolso)     
    
    
    
select dbo.fdufechaaperiodo(t.desembolso) periodo    
,sum(case when  t.NroDiasAtraso < 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3'    
,sum(case when  t.NroDiasAtraso >= 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3'    
,sum(case when  t.NroDiasAtraso >= 3 then 1 else 0 end ) as 'nrocermay3'    
,sum(case when  t.NroDiasAtraso >= 3 then isnull(t.monto,0) else 0 end ) as 'montocermay3'    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c1'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c1'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=1 then 1 else 0 end ) as 'nrocermay3c1'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=1 then isnull(t.monto,0) else 0 end ) as 'montocermay3c1'    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo=2  then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c2'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c2'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=2 then 1 else 0 end ) as 'nrocermay3c2'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=2 then isnull(t.monto,0) else 0 end ) as 'montocermay3c2'    
into #carteraactivamiio    
from carteraactivamiio  t with(nolock)    
INNER join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo    
where dbo.fdufechaaperiodo(t.desembolso)>='202210'    
group by dbo.fdufechaaperiodo(t.desembolso)     
order by  dbo.fdufechaaperiodo(t.desembolso)     
    
    
    
select     
a.periodo    
,colocacion    
,cer3 as 'capitalvigente'    
,cermay3 as 'cer3may'    
,case when isnull(nrocermay3,0)=0 then 0 else isnull(montocermay3,0)/nrocermay3 end as 'ticketpromcermay3'    
,case when isnull(colocacion,0)=0 then 0 else isnull(cermay3,0)*100/colocacion end as deterioro    
,'Total' as ciclo    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
union    
select     
a.periodo    
,colocacionc1    
,cer3c1 as 'capitalvigente'    
,cermay3c1 as 'cer3may'    
,case when isnull(nrocermay3c1,0)=0 then 0 else isnull(montocermay3c1,0)/nrocermay3c1 end as 'ticketpromcermay3'    
,case when isnull(colocacionc1,0)=0 then 0 else isnull(cermay3c1,0)*100/colocacionc1 end as deterioro    
,'1' as ciclo    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
union    
select     
a.periodo    
,colocacionc2    
,cer3c2 as 'capitalvigente'    
,cermay3c2 as 'cer3may'    
,case when isnull(nrocermay3c2,0)=0 then 0 else isnull(montocermay3c2,0)/nrocermay3c2 end as 'ticketpromcermay3'    
,case when isnull(colocacionc2,0)=0 then 0 else isnull(cermay3c2,0)*100/colocacionc2 end as deterioro    
,'2' as ciclo    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
    
    
    
    
drop table #grafanamiio    
drop table #carteraactivamiio    
    
GO