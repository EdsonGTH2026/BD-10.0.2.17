SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[objetivomiiotab1] as 
select 
dbo.fdufechaaperiodo(p.desembolso) periodo
,sum(case when p.ciclo=1 then p.monto else 0 end) as 'colocacionc1'
,sum(case when p.ciclo=1 then 1 else 0 end) as 'nroc1'
,case when sum(case when p.ciclo=1 then 1 else 0 end)=0 then 0 else round(sum(case when p.ciclo=1 then p.monto else 0 end)/sum(case when p.ciclo=1 then 1 else 0 end),0)end as 'TICKETPROMEDIOc1'
,sum(case when p.ciclo=2 then p.monto else 0 end) as 'colocacionc2'
,sum(case when p.ciclo=2 then 1 else 0 end) as 'nroc2'
,case when sum(case when p.ciclo=2 then 1 else 0 end)=0 then 0 else round(sum(case when p.ciclo=2 then p.monto else 0 end)/sum(case when p.ciclo=2 then 1 else 0 end),0) end as 'TICKETPROMEDIOc2'
,sum(case when p.ciclo>=3 and p.ciclo<=4 then p.monto else 0 end) as 'colocacionc3_4'
,sum(case when p.ciclo>=3 and p.ciclo<=4 then 1 else 0 end) as 'nroc3_4'
,case when sum(case when p.ciclo>=3 and p.ciclo<=4 then 1 else 0 end)=0 then 0 else round(sum(case when p.ciclo>=3 and p.ciclo<=4 then p.monto else 0 end)/sum(case when p.ciclo>=3 and p.ciclo<=4 then 1 else 0 end),0) end as 'TICKETPROMEDIOc3_4'
,sum(case when p.ciclo>=5 and p.ciclo<=6 then p.monto else 0 end) as 'colocacionc5_6'
,sum(case when p.ciclo>=5 and p.ciclo<=6 then 1 else 0 end) as 'nroc5_6'
,case when sum(case when p.ciclo>=5 and p.ciclo<=6 then 1 else 0 end)=0 then 0 else round(sum(case when p.ciclo>=5 and p.ciclo<=6 then p.monto else 0 end)/sum(case when p.ciclo>=5 and p.ciclo<=6 then 1 else 0 end),0) end  as 'TICKETPROMEDIOc5_6'
,sum(case when p.ciclo>=7 then p.monto else 0 end) as 'colocacionc7'
,sum(case when p.ciclo>=7 then 1 else 0 end) as 'nroc7'
,case when sum(case when p.ciclo>=7 then 1 else 0 end)=0 then 0 else round(sum(case when p.ciclo>=7 then p.monto else 0 end)/sum(case when p.ciclo>=7 then 1 else 0 end),0)end as 'TICKETPROMEDIOc7'
into #grafanamiio
from tcsgrafanamiio p with(nolock) 
group by dbo.fdufechaaperiodo(p.desembolso) 
order by  dbo.fdufechaaperiodo(p.desembolso) desc



select dbo.fdufechaaperiodo(t.desembolso) periodo
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente1'
,sum(case when  t.NroDiasAtraso > 3 and d.ciclo=1 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido1'
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente2'
,sum(case when  t.NroDiasAtraso > 3 and d.ciclo=2 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido2'
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo>=3 and d.ciclo<=4 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente3_4'
,sum(case when  t.NroDiasAtraso > 3 and d.ciclo>=3 and d.ciclo<=4  then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido3_4'
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo>=5 and d.ciclo<=6 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente5_6'
,sum(case when  t.NroDiasAtraso > 3 and d.ciclo>=5 and d.ciclo<=6  then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido5_6'
,sum(case when  t.NroDiasAtraso < 3 and d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvigente7'
,sum(case when  t.NroDiasAtraso > 3 and d.ciclo>=7 then isnull(t.SaldoCapital,0) else 0 end ) as 'capitalvencido7'
into #carteraactivamiio
from carteraactivamiio  t with(nolock)
left outer join tcsCicloMIIO_230920 d on d.codprestamo=t.codprestamo
group by dbo.fdufechaaperiodo(t.desembolso) 
order by  dbo.fdufechaaperiodo(t.desembolso) desc



select dbo.fdufechaaperiodo(fecha) periodo
,sum(case when d.ciclo=1 then p.interes+p.moratorios2 else 0 end) as 'totalinteres1'
,sum(case when d.ciclo=2 then p.interes+p.moratorios2 else 0 end) as 'totalinteres2'
,sum(case when d.ciclo>=3 and d.ciclo<4  then p.interes+p.moratorios2 else 0 end) as 'totalinteres3_4'
,sum(case when d.ciclo>=5 and d.ciclo<6  then p.interes+p.moratorios2 else 0 end) as 'totalinteres5_6'
,sum(case when d.ciclo>=7  then p.interes+p.moratorios2 else 0 end) as 'totalinteres7'
into #tcscobranzamiio
from tcscobranzamiio p with(nolock)
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo 
group by dbo.fdufechaaperiodo(fecha) 
order by  dbo.fdufechaaperiodo(fecha) desc

select dbo.fdufechaaperiodo(fecha) periodo
,sum(case when d.ciclo=1 and cer=1 then p.saldocapital else 0 end) as 'saldocierre1'
,sum(case when d.ciclo=2 and cer=1 then p.saldocapital else 0 end) as 'saldocierre2'
,sum(case when d.ciclo>=3 and d.ciclo<=4 and cer=1 then p.saldocapital else 0 end) as 'saldocierre3_4'
,sum(case when d.ciclo>=5 and d.ciclo<=6 and cer=1 then p.saldocapital else 0 end) as 'saldocierre5_6'
,sum(case when d.ciclo>=7 and cer=1 then p.saldocapital else 0 end) as 'saldocierre7'
into #tcsCierremesMiio
from tcsCierremesMiio p with(nolock)
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo
group by dbo.fdufechaaperiodo(fecha) 
order by  dbo.fdufechaaperiodo(fecha) desc


select  dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) periodo
,sum(case when d.ciclo=1 and cer=1 then p.saldocapital else 0 end) as 'saldocierre1'
,sum(case when d.ciclo=2 and cer=1 then p.saldocapital else 0 end) as 'saldocierre2'
,sum(case when d.ciclo>=3 and d.ciclo<=4 and cer=1 then p.saldocapital else 0 end) as 'saldocierre3_4'
,sum(case when d.ciclo>=5 and d.ciclo<=6 and cer=1 then p.saldocapital else 0 end) as 'saldocierre5_6'
,sum(case when d.ciclo>=7 and cer=1 then p.saldocapital else 0 end) as 'saldocierre7'
into #tcsCierremesMiiounion
from tcsCierremesMiio p with(nolock)
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo
group by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime))
order by  dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) desc



select top 2 g.periodo
,g.colocacionc1
,g.nroc1
,g.TICKETPROMEDIOc1
,case when isnull(g.colocacionc1,0)=0 then 0 else isnull(a.capitalvencido1,0)/g.colocacionc1 end as 'deterioro'
,a.capitalvigente1
,isnull(b.totalinteres1,0)-(isnull(c.saldocierre1,0)-isnull(cu.saldocierre1,0)) as 'flujo'
,'1' as 'ciclo'
into #objetivoc1
from #grafanamiio g
inner join  #carteraactivamiio a on a.periodo=g.periodo
inner join #tcscobranzamiio b  on b.periodo=g.periodo
inner join  #tcsCierremesMiio c on c.periodo=g.periodo
inner join  #tcsCierremesMiiounion cu on cu.periodo=g.periodo
order by   g.periodo desc

select top 2 g.periodo
,g.colocacionc2
,g.nroc2
,g.TICKETPROMEDIOc2
,case when isnull(g.colocacionc2,0)=0 then 0 else isnull(a.capitalvencido2,0)/g.colocacionc2 end as 'deterioro'
,a.capitalvigente2
,isnull(b.totalinteres2,0)-(isnull(c.saldocierre2,0)-isnull(cu.saldocierre2,0)) as 'flujo'
,'2' as 'ciclo'
into #objetivoc2
from #grafanamiio g
inner join  #carteraactivamiio a on a.periodo=g.periodo
inner join #tcscobranzamiio b  on b.periodo=g.periodo
inner join  #tcsCierremesMiio c on c.periodo=g.periodo
inner join  #tcsCierremesMiiounion cu on cu.periodo=g.periodo
order by   g.periodo desc

select top 2 g.periodo
,g.colocacionc3_4
,g.nroc3_4
,g.TICKETPROMEDIOc3_4
,case when isnull(g.colocacionc3_4,0)=0 then 0 else isnull(a.capitalvencido3_4,0)/g.colocacionc3_4 end as 'deterioro'
,a.capitalvigente3_4
,isnull(b.totalinteres3_4,0)-(isnull(c.saldocierre3_4,0)-isnull(cu.saldocierre3_4,0)) as 'flujo'
,'3-4' as 'ciclo'
into #objetivoc3_4
from #grafanamiio g
inner join  #carteraactivamiio a on a.periodo=g.periodo
inner join #tcscobranzamiio b  on b.periodo=g.periodo
inner join  #tcsCierremesMiio c on c.periodo=g.periodo
inner join  #tcsCierremesMiiounion cu on cu.periodo=g.periodo
order by   g.periodo desc



select top 2 g.periodo
,g.colocacionc5_6
,g.nroc5_6
,g.TICKETPROMEDIOc5_6
,case when isnull(g.colocacionc5_6,0)=0 then 0 else isnull(a.capitalvencido5_6,0)/g.colocacionc5_6 end as 'deterioro'
,a.capitalvigente5_6
,isnull(b.totalinteres5_6,0)-(isnull(c.saldocierre5_6,0)-isnull(cu.saldocierre5_6,0)) as 'flujo'
,'5-6' as 'ciclo'
into #objetivoc5_6
from #grafanamiio g
inner join  #carteraactivamiio a on a.periodo=g.periodo
inner join #tcscobranzamiio b  on b.periodo=g.periodo
inner join  #tcsCierremesMiio c on c.periodo=g.periodo
inner join  #tcsCierremesMiiounion cu on cu.periodo=g.periodo
order by   g.periodo desc


select top 2 g.periodo
,g.colocacionc7
,g.nroc7
,g.TICKETPROMEDIOc7
,case when isnull(g.colocacionc7,0)=0 then 0 else isnull(a.capitalvencido7,0)/g.colocacionc7 end as 'deterioro'
,a.capitalvigente7
,isnull(b.totalinteres7,0)-(isnull(c.saldocierre7,0)-isnull(cu.saldocierre7,0)) as 'flujo'
,'7+' as 'ciclo'
into #objetivoc7
from #grafanamiio g
inner join  #carteraactivamiio a on a.periodo=g.periodo
inner join #tcscobranzamiio b  on b.periodo=g.periodo
inner join  #tcsCierremesMiio c on c.periodo=g.periodo
inner join  #tcsCierremesMiiounion cu on cu.periodo=g.periodo
order by   g.periodo desc


select *
from #objetivoc1
union
select *
from #objetivoc2
union
select *
from #objetivoc3_4
union
select *
from #objetivoc5_6
union
select *
from #objetivoc7






drop table #grafanamiio
drop table #carteraactivamiio
drop table #tcscobranzamiio
drop table #tcsCierremesMiiounion 
drop table #tcsCierremesMiio
drop table #objetivoc1
drop table #objetivoc2
drop table #objetivoc3_4
drop table #objetivoc5_6
drop table #objetivoc7
GO