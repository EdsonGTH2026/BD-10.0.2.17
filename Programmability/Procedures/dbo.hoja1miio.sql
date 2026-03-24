SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[hoja1miio] as     
    
select     
dbo.fdufechaaperiodo(p.desembolso) periodo    
,sum(p.monto) as 'colocacion'    
,sum(case when p.ciclo=1 then p.monto else 0 end) as 'colocacionc1'    
,sum(case when p.ciclo=2 then p.monto else 0 end) as 'colocacionc2'    
,sum(case when p.ciclo>=3 and ciclo<=4 then p.monto else 0 end) as 'colocacionc3_4'    
,sum(case when p.ciclo>=5 and ciclo<=6 then p.monto else 0 end) as 'colocacionc5_6'    
,sum(case when p.ciclo>=7 then p.monto else 0 end) as 'colocacionc7'    
--,count(p.codprestamo) as 'nro'    
--,round(sum(p.monto)/COUNT(p.CODPRESTAMO),0) TICKETPROMEDIO    
into #grafanamiio    
from tcsgrafanamiio p with(nolock)     
group by dbo.fdufechaaperiodo(p.desembolso)     
order by  dbo.fdufechaaperiodo(p.desembolso)     
    
    
select dbo.fdufechaaperiodo(t.desembolso) periodo    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente1'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido1'    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente2'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido2'    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente3_4'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=3 and d.ciclo<=4  then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido3_4'    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente5_6'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=5 and d.ciclo<=6  then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido5_6'    
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente7'    
,sum(case when  t.NroDiasAtraso >= 3 and d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido7'    
into #carteraactivamiio    
from carteraactivamiio  t with(nolock)    
inner join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo    
group by dbo.fdufechaaperiodo(t.desembolso)     
order by  dbo.fdufechaaperiodo(t.desembolso) desc    
    
    
    
    
    
    
    
    
select dbo.fdufechaaperiodo(fecha) periodo    
,sum(p.saldocapital) as 'saldocierre'    
,sum(case when d.ciclo=1 and  cer=1 then p.saldocapital else 0 end) as 'saldocierre1'    
,sum(case when d.ciclo=2 and cer=1 then p.saldocapital else 0 end) as 'saldocierre2'    
,sum(case when d.ciclo>=3 and d.ciclo<=4 and cer=1 then p.saldocapital else 0 end) as 'saldocierre3_4'    
,sum(case when d.ciclo>=5 and d.ciclo<=6 and cer=1 then p.saldocapital else 0 end) as 'saldocierre5_6'    
,sum(case when d.ciclo>=7 and cer=1 then p.saldocapital else 0 end) as 'saldocierre7'    
into #tcsCierremesMiio    
from tcsCierremesMiio p with(nolock)    
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo    
where cer=1    
group by dbo.fdufechaaperiodo(fecha)     
order by  dbo.fdufechaaperiodo(fecha)     
    
    
select dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) periodo    
,sum(p.saldocapital) as 'saldocierre'    
,sum(case when d.ciclo=1 and  cer=1 then p.saldocapital else 0 end) as 'saldocierre1'    
,sum(case when d.ciclo=2 and cer=1 then p.saldocapital else 0 end) as 'saldocierre2'    
,sum(case when d.ciclo>=3 and d.ciclo<=4 and cer=1 then p.saldocapital else 0 end) as 'saldocierre3_4'    
,sum(case when d.ciclo>=5 and d.ciclo<=6 and cer=1 then p.saldocapital else 0 end) as 'saldocierre5_6'    
,sum(case when d.ciclo>=7 and cer=1 then p.saldocapital else 0 end) as 'saldocierre7'    
into #tcsCierremesMiiounion    
from tcsCierremesMiio p with(nolock)    
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo    
where  cer=1    
group by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime))    
order by  dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime))     
    
    
    
    
select a.periodo,g.colocacion,a.saldocierre-isnull(b.saldocierre,0) as 'DeltaCer3+'    
,a.saldocierre1-isnull(b.saldocierre1,0) as 'DeltaCer3+1'    
,case when a.periodo='202210' then null
	when a.saldocierre=isnull(b.saldocierre,0) then 0
	else (a.saldocierre1-isnull(b.saldocierre1,0))*100/(a.saldocierre-isnull(b.saldocierre,0)) end as '% delta'    
--,ac.capitalvencido1/g.colocacionc1 as 'deterioro' 
,case when isnull(g.colocacionc1,0)=0 then 0 else ac.capitalvencido1/g.colocacionc1 end   as 'deterioro' 
, '1' as 'ciclo'    
into #ciclomiio1    
from  #tcsCierremesMiio a    
left outer join #grafanamiio g on g.periodo=a.periodo    
left outer join #tcsCierremesMiiounion b on a.periodo=b.periodo    
left outer join #carteraactivamiio ac on ac.periodo=a.periodo    
where a.periodo<>'202401'    
order by a.periodo    
    
select a.periodo,g.colocacion,a.saldocierre-isnull(b.saldocierre,0) as 'DeltaCer3+'    
,a.saldocierre2-isnull(b.saldocierre2,0) as 'DeltaCer3+2'    
,case when a.periodo='202210' then null 
	when a.saldocierre=isnull(b.saldocierre,0) then 0
	else (a.saldocierre2-isnull(b.saldocierre2,0))*100/(a.saldocierre-isnull(b.saldocierre,0)) end as '% delta'    
--,ac.capitalvencido2/g.colocacionc2 as 'deterioro' 
,case when isnull(g.colocacionc2,0)=0 then 0 else ac.capitalvencido2/g.colocacionc2 end   as 'deterioro'  
, '2' as 'ciclo'    
into #ciclomiio2    
from  #tcsCierremesMiio a    
left outer join #grafanamiio g on g.periodo=a.periodo    
left outer join #tcsCierremesMiiounion b on a.periodo=b.periodo    
left outer join #carteraactivamiio ac on ac.periodo=a.periodo    
where a.periodo<>'202401'    
order by a.periodo    
    
    
select a.periodo,g.colocacion,a.saldocierre-isnull(b.saldocierre,0) as 'DeltaCer3+'    
,a.saldocierre3_4-isnull(b.saldocierre3_4,0) as 'DeltaCer3+3_4'    
,case when a.periodo='202210' then null 
	when a.saldocierre=isnull(b.saldocierre,0) then 0
	else (a.saldocierre3_4-isnull(b.saldocierre3_4,0))*100/(a.saldocierre-isnull(b.saldocierre,0)) end as '% delta'    
--,ac.capitalvencido3_4/g.colocacionc3_4 as 'deterioro'
,case when isnull(g.colocacionc3_4,0)=0 then 0 else ac.capitalvencido3_4/g.colocacionc3_4 end   as 'deterioro' 
, '3_4' as 'ciclo'    
into #ciclomiio3_4    
from  #tcsCierremesMiio a    
left outer join #grafanamiio g on g.periodo=a.periodo    
left outer join #tcsCierremesMiiounion b on a.periodo=b.periodo    
left outer join #carteraactivamiio ac on ac.periodo=a.periodo    
where a.periodo<>'202401'    
order by a.periodo    
    
    
    
select a.periodo,g.colocacion,a.saldocierre-isnull(b.saldocierre,0) as 'DeltaCer3+'    
,a.saldocierre5_6-isnull(b.saldocierre5_6,0) as 'DeltaCer3+5_6'    
,case when a.periodo='202210' then null
	when a.saldocierre=isnull(b.saldocierre,0) then 0
	else (a.saldocierre5_6-isnull(b.saldocierre5_6,0))*100/(a.saldocierre-isnull(b.saldocierre,0)) end as '% delta'    
--,ac.capitalvencido5_6/g.colocacionc5_6 as 'deterioro' 
,case when isnull(g.colocacionc5_6,0)=0 then 0 else ac.capitalvencido5_6/g.colocacionc5_6 end   as 'deterioro' 
, '5_6' as 'ciclo'    
into #ciclomiio5_6    
from  #tcsCierremesMiio a    
left outer join #grafanamiio g on g.periodo=a.periodo    
left outer join #tcsCierremesMiiounion b on a.periodo=b.periodo    
left outer join #carteraactivamiio ac on ac.periodo=a.periodo    
where a.periodo<>'202401'    
order by a.periodo    
    
    
select a.periodo,g.colocacion,a.saldocierre-isnull(b.saldocierre,0) as 'DeltaCer3+'    
,a.saldocierre7-isnull(b.saldocierre7,0) as 'DeltaCer3+7'    
,case when a.periodo='202210' then null 
	when a.saldocierre=isnull(b.saldocierre,0) then 0
	else (a.saldocierre7-isnull(b.saldocierre7,0))*100/(a.saldocierre-isnull(b.saldocierre,0)) end as '% delta'  
--,ac.capitalvencido7/g.colocacionc7 as 'deterioro'  
,case when isnull(g.colocacionc7,0)=0 then 0 else ac.capitalvencido7/g.colocacionc7 end   as 'deterioro' 
, '7+' as 'ciclo'    
into #ciclomiio7    
from  #tcsCierremesMiio a    
left outer join #grafanamiio g on g.periodo=a.periodo    
left outer join #tcsCierremesMiiounion b on a.periodo=b.periodo    
left outer join #carteraactivamiio ac on ac.periodo=a.periodo    
where a.periodo<>'202401'    
order by a.periodo    
    
    
select *    
from #ciclomiio1    
union    
select *    
from #ciclomiio2    
union    
select *    
from #ciclomiio3_4    
union    
select *    
from #ciclomiio5_6    
union    
select *    
from #ciclomiio7    
    
    
    
    
    
drop table #tcsCierremesMiio     
drop table #tcsCierremesMiiounion    
drop table #grafanamiio    
drop table #carteraactivamiio    
drop table #ciclomiio1    
drop table #ciclomiio2    
drop table #ciclomiio3_4    
drop table #ciclomiio5_6    
drop table #ciclomiio7
GO