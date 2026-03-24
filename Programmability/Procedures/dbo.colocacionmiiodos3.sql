SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[colocacionmiiodos3] as     
    
select  dbo.fdufechaaperiodo(p.desembolso) periodo      
,sum(case when ciclo=1 then p.monto else 0 end ) as 'colocacionop1'      
,sum(case when ciclo=1 then 1 else 0 end ) as 'nroop1'      
,sum(case when ciclo=2 then p.monto else 0 end ) as 'colocacionop2'      
,sum(case when ciclo=2 then 1 else 0 end ) as 'nroop2'      
,sum(case when ciclo>=3 and ciclo<=4 then p.monto else 0 end ) as 'colocacionop3_4'      
,sum(case when ciclo>=3 and ciclo<=4 then 1 else 0 end ) as 'nroop3_4'      
,sum(case when ciclo>=5 and ciclo<=6 then p.monto else 0 end ) as 'colocacionop5_6'      
,sum(case when ciclo>=5 and ciclo<=6 then 1 else 0 end ) as 'nroop5_6'      
,sum(case when ciclo>=7 then p.monto else 0 end ) as 'colocacionop7'      
,sum(case when ciclo>=7 then 1 else 0 end ) as 'nroop7'      
into #grafanamiio      
from tcsgrafanamiio p with(nolock)       
group by dbo.fdufechaaperiodo(p.desembolso)       
order by  dbo.fdufechaaperiodo(p.desembolso)       
      
      
      
select dbo.fdufechaaperiodo(t.desembolso) periodo      
,sum(case when  d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'saldoc1'      
,sum(case when  t.NroDiasAtraso < 3 and  d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c1'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c1'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo=1 then 1 else 0 end ) as 'cermay3c1nro1'      
,sum(case when  d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'saldoc2'      
,sum(case when  t.NroDiasAtraso < 3 and  d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c2'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c2'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo=2 then 1 else 0 end ) as 'cermay3c1nro2'      
,sum(case when  d.ciclo >=3 and d.ciclo<=4  then isnull(t.SaldoCapital,0) else 0 end ) as 'saldoc3_4'      
,sum(case when  t.NroDiasAtraso < 3 and  d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c3_4'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c3_4'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=3 and d.ciclo<=4 then 1 else 0 end ) as 'cermay3c1nro3_4'      
,sum(case when  d.ciclo>=5 and d.ciclo<=6  then isnull(t.SaldoCapital,0) else 0 end ) as 'saldoc5_6'      
,sum(case when  t.NroDiasAtraso < 3 and  d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c5_6'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c5_6'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=5 and d.ciclo<=6 then 1 else 0 end ) as 'cermay3c1nro5_6'      
,sum(case when  d.ciclo>=7  then isnull(t.SaldoCapital,0) else 0 end ) as 'saldoc7'      
,sum(case when  t.NroDiasAtraso < 3 and  d.ciclo>=7  then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3c7'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3c7'      
,sum(case when  t.NroDiasAtraso >= 3 and  d.ciclo>=7  then 1 else 0 end ) as 'cermay3c1nro7'      
into #carteraactivamiio      
from carteraactivamiio  t with(nolock)      
inner join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo      
where dbo.fdufechaaperiodo(t.desembolso)>='202210'      
group by dbo.fdufechaaperiodo(t.desembolso)       
order by  dbo.fdufechaaperiodo(t.desembolso)       
      
      
      
select       
a.periodo      
,colocacionop1      
,isnull(colocacionop1,0)-isnull(saldoc1,0)      
,saldoc1      
,cer3c1      
,cermay3c1      
,case when isnull(nroop1,0)=0 then 0 else isnull(colocacionop1,0)/nroop1 end as ticketpromedio      
,nroop1      
,cermay3c1nro1      
,case when isnull(colocacionop1,0)=0 then 0 else isnull(cermay3c1,0)*100/colocacionop1 end as '%cer+$'      
,case when isnull(colocacionop1,0)=0 then 0 else (isnull(colocacionop1,0)-isnull(saldoc1,0))*100/colocacionop1 end as '%cap-pag'      
,case when isnull(nroop1,0)=0 then 0 else cast(isnull(cermay3c1nro1,0) as money)*100/nroop1 end as '%nrocer+'      
,'1' as ciclo      
from #grafanamiio g      
inner join  #carteraactivamiio a on a.periodo=g.periodo      
union      
select       
a.periodo      
,colocacionop2      
,isnull(colocacionop2,0)-isnull(saldoc2,0)      
,saldoc2      
,cer3c2      
,cermay3c2      
,case when isnull(nroop2,0)=0 then 0 else isnull(colocacionop2,0)/nroop2 end as ticketpromedio      
,nroop2      
,cermay3c1nro2      
,case when isnull(colocacionop2,0)=0 then 0 else isnull(cermay3c2,0)*100/colocacionop2 end as '%cer+$'     
,case when isnull(colocacionop2,0)=0 then 0 else (isnull(colocacionop2,0)-isnull(saldoc2,0))*100/colocacionop2 end as '%cap-pag'      
,case when isnull(nroop2,0)=0 then 0 else cast(isnull(cermay3c1nro2,0) as money)*100/nroop2 end as '%nrocer+'      
,'2' as ciclo      
from #grafanamiio g      
inner join  #carteraactivamiio a on a.periodo=g.periodo      
union      
select       
a.periodo      
,colocacionop3_4      
,isnull(colocacionop3_4,0)-isnull(saldoc3_4,0)      
,saldoc3_4      
,cer3c3_4      
,cermay3c3_4      
,case when isnull(nroop3_4,0)=0 then 0 else isnull(colocacionop3_4,0)/nroop3_4 end as ticketpromedio      
,nroop3_4      
,cermay3c1nro3_4      
,case when isnull(colocacionop3_4,0)=0 then 0 else isnull(cermay3c3_4,0)*100/colocacionop3_4 end as '%cer+$'     
,case when isnull(colocacionop3_4,0)=0 then 0 else (isnull(colocacionop3_4,0)-isnull(saldoc3_4,0))*100/colocacionop3_4 end as '%cap-pag'      
,case when isnull(nroop3_4,0)=0 then 0 else cast(isnull(cermay3c1nro3_4,0) as money)*100/nroop3_4 end as '%nrocer+'      
,'3_4' as ciclo      
from #grafanamiio g      
inner join  #carteraactivamiio a on a.periodo=g.periodo      
union      
select       
a.periodo      
,colocacionop5_6      
,isnull(colocacionop5_6,0)-isnull(saldoc5_6,0)      
,saldoc5_6      
,cer3c5_6      
,cermay3c5_6      
--,colocacionop5_6/nroop5_6 as ticketpromedio   
,case when isnull(nroop5_6,0)=0 then 0 else isnull(colocacionop5_6,0)/nroop5_6 end as ticketpromedio      
,nroop5_6      
,cermay3c1nro5_6      
,case when isnull(colocacionop5_6,0)=0 then 0 else isnull(cermay3c5_6,0)*100/colocacionop5_6 end as '%cer+$'     
,case when isnull(colocacionop5_6,0)=0 then 0 else (isnull(colocacionop5_6,0)-isnull(saldoc5_6,0))*100/colocacionop5_6 end as '%cap-pag'      
,case when isnull(nroop5_6,0)=0 then 0 else cast(isnull(cermay3c1nro5_6,0) as money)*100/nroop5_6 end as '%nrocer+'      
,'5_6' as ciclo      
from #grafanamiio g      
inner join  #carteraactivamiio a on a.periodo=g.periodo      
union      
select       
a.periodo      
,colocacionop7      
,isnull(colocacionop7,0)-isnull(saldoc7,0)      
,saldoc7      
,cer3c7      
,cermay3c7      
--,colocacionop7/nroop7 as ticketpromedio 
,case when isnull(nroop7,0)=0 then 0 else isnull(colocacionop7,0)/nroop7 end as ticketpromedio      
,nroop7      
,cermay3c1nro7      
,case when isnull(colocacionop7,0)=0 then 0 else isnull(cermay3c7,0)*100/colocacionop7 end as '%cer+$'     
,case when isnull(colocacionop7,0)=0 then 0 else (isnull(colocacionop7,0)-isnull(saldoc7,0))*100/colocacionop7 end as '%cap-pag'      
,case when isnull(nroop7,0)=0 then 0 else cast(isnull(cermay3c1nro7,0) as money)*100/nroop7 end as '%nrocer+'      
,'7' as ciclo      
from #grafanamiio g      
inner join  #carteraactivamiio a on a.periodo=g.periodo      
      
      
      
drop table #grafanamiio      
drop table #carteraactivamiio
GO