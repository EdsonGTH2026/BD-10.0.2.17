SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext cosechamiiotab4

CREATE procedure [dbo].[cosechamiiotab4] 
as   
  
select  dbo.fdufechaaperiodo(p.desembolso) periodo    
,sum(p.monto) as 'colocacion'    
,sum(case when ciclo>=3 and ciclo<=4 then p.monto else 0 end) as 'colocacionc3_4'    
,sum(case when ciclo>=5 and ciclo<=6 then p.monto else 0 end) as 'colocacionc5_6'    
,sum(case when ciclo>=7  then p.monto else 0 end) as 'colocacionc7'    
into #grafanamiio    
from tcsgrafanamiio p with(nolock)     
group by dbo.fdufechaaperiodo(p.desembolso)     
order by  dbo.fdufechaaperiodo(p.desembolso)     
    
    
    
select dbo.fdufechaaperiodo(t.desembolso) periodo    
,sum(case when  t.NroDiasAtraso <= 2 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3'    
,sum(case when  t.NroDiasAtraso >= 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3'    
,sum(case when  t.NroDiasAtraso >= 3 then 1 else 0 end ) as 'nrocermay3'    
,sum(case when  t.NroDiasAtraso >= 3 then isnull(t.monto,0) else 0 end ) as 'montocermay3'    
,sum(case when  t.NroDiasAtraso <= 2 and d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c3_4'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c3_4'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=3 and d.ciclo<=4 then 1 else 0 end ) as 'nrocermay3c3_4'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=3 and d.ciclo<=4 then isnull(t.monto,0) else 0 end ) as 'montocermay3c3_4'    
,sum(case when  t.NroDiasAtraso <= 2 and d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c5_6'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c5_6'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=5 and d.ciclo<=6 then 1 else 0 end ) as 'nrocermay3c5_6'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=5 and d.ciclo<=6 then isnull(t.monto,0) else 0 end ) as 'montocermay3c5_6'    
,sum(case when  t.NroDiasAtraso <= 2 and d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c7'    
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c7'    
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=7 then 1 else 0 end ) as 'nrocermay3c7'    
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=7 then isnull(t.monto,0) else 0 end ) as 'montocermay3c7'    
into #carteraactivamiio    
from carteraactivamiio  t with(nolock)    
INNER join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo    
where dbo.fdufechaaperiodo(t.desembolso)>='202210'    
group by dbo.fdufechaaperiodo(t.desembolso)     
order by  dbo.fdufechaaperiodo(t.desembolso)     
    
    
    
    
select     
a.periodo    
,colocacionc3_4    
,cer3c3_4 as 'capitalvigente'    
,cermay3c3_4 as 'cer3may'    
,case when isnull(nrocermay3c3_4,0)=0 then 0 else isnull(montocermay3c3_4,0)/nrocermay3c3_4 end as 'ticketpromcermay3'    
,case when isnull(colocacionc3_4,0)=0 then 0 else isnull(cermay3c3_4,0)*100/colocacionc3_4 end as deterioro    
,'3_4' as ciclo    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
union    
select     
a.periodo    
,colocacionc5_6    
,cer3c5_6 as 'capitalvigente'    
,cermay3c5_6 as 'cer3may'    
,case when isnull(nrocermay3c5_6,0)=0 then 0 else isnull(montocermay3c5_6,0)/nrocermay3c5_6 end as 'ticketpromcermay3'    
,case when isnull(colocacionc5_6,0)=0 then 0 else isnull(cermay3c5_6,0)*100/colocacionc5_6 end as deterioro    
,'5_6' as ciclo    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
union    
select     
a.periodo    
,colocacionc7    
,cer3c7 as 'capitalvigente'    
,cermay3c7 as 'cer3may'    
,case when isnull(nrocermay3c7,0)=0 then 0 else isnull(montocermay3c7,0)/nrocermay3c7 end as 'ticketpromcermay3'    
,case when isnull(colocacionc7,0)=0 then 0 else isnull(cermay3c7,0)*100/colocacionc7 end as deterioro    
,'7' as ciclo    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
    
    
    
    
drop table #grafanamiio    
drop table #carteraactivamiio    
    
GO