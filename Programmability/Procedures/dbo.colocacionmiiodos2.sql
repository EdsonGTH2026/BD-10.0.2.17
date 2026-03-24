SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT colocacionmiiodos2

CREATE procedure [dbo].[colocacionmiiodos2] as   
  
select  dbo.fdufechaaperiodo(p.desembolso) periodo    
,sum(p.monto) as 'colocacion'    
,count(p.codprestamo) as 'nro'    
,sum(case when p.monto>499 and ciclo>=3 then p.monto else 0 end ) as 'colocacionop1'    
,sum(case when p.monto>499 and ciclo>=3 then 1 else 0 end ) as 'nroop1'    
into #grafanamiio    
from tcsgrafanamiio p with(nolock)     
group by dbo.fdufechaaperiodo(p.desembolso)     
order by  dbo.fdufechaaperiodo(p.desembolso)     
    
    
    
    
select dbo.fdufechaaperiodo(t.desembolso) periodo    
,sum(case when  t.NroDiasAtraso < 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3'    
,sum(case when  t.NroDiasAtraso < 3 then 1 else 0 end ) as 'nrocer3'    
,sum(case when  t.NroDiasAtraso >= 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3'    
,sum(case when  t.NroDiasAtraso >= 3 then 1 else 0 end ) as 'nrocermay3'    
,sum(case when  t.NroDiasAtraso >= 3 and monto>499 and d.ciclo>=3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3op1'    
,sum(case when  t.NroDiasAtraso >= 3 and monto>499 and d.ciclo>=3 then 1 else 0 end ) as 'nrocermay3op1'    
,sum(case when  t.NroDiasAtraso < 3 and monto>499 and d.ciclo>=3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3op1'    
into #carteraactivamiio    
from carteraactivamiio  t with(nolock)    
INNER join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo    
where dbo.fdufechaaperiodo(t.desembolso)>='202210'    
group by dbo.fdufechaaperiodo(t.desembolso)     
order by  dbo.fdufechaaperiodo(t.desembolso)     
    
    
    
select     
a.periodo    
,nro    
,colocacion    
,case when isnull(nro,0)=0 then 0 else isnull(colocacion,0)/nro end as 'ticket promedio'    
,nrocermay3    
,case when isnull(nro,0)=0 then 0 else cast(isnull(nrocermay3,0) as money)*100/nro end as 'nrocre3may%'    
,cermay3 as 'cer3may'    
,case when isnull(colocacion,0)=0 then 0 else isnull(cermay3,0)*100/colocacion  end as '%cer3may'    
,cer3    
,nroop1    
,case when isnull(nro,0)=0 then 0 else cast(isnull(nroop1,0) as money)*100/nro end as '#subgrup%'    
,colocacionop1    
,case when isnull(colocacion,0)=0 then 0 else  isnull(colocacionop1,0)*100/colocacion end as 'colocgroup'    
,case when isnull(nroop1,0)=0 then 0 else isnull(colocacionop1,0)/nroop1 end as 'ticketpromop1'    
,nrocermay3op1    
,case when isnull(nroop1,0)=0 then 0 else cast(isnull(nrocermay3op1,0) as money)*100/nroop1 end as '%nrocermay3op1'    
,cermay3op1    
,case when isnull(colocacionop1,0)=0 then 0 else isnull(cermay3op1,0)*100/colocacionop1 end '%cermay3op1'    
,cer3op1    
,case when isnull(cermay3,0)=0 then 0 else isnull(cermay3op1,0)*100/cermay3 end as '%cermay3op1seg'    
,case when isnull(nrocermay3,0)=0 then 0 else cast(isnull(nrocermay3op1,0) as money)*100/nrocermay3 end as 'nrocre3may%'    
from #grafanamiio g    
inner join  #carteraactivamiio a on a.periodo=g.periodo    
    
    
drop table #grafanamiio    
drop table #carteraactivamiio
GO