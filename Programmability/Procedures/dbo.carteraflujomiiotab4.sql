SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[carteraflujomiiotab4] as   
  
  
select dbo.fdufechaaperiodo(fecha) periodo  
,sum(case when cer=0 then 1 else 0 end) as 'credvig'  
,sum(case when cer=1 then 1 else 0 end) as 'credven'  
,sum(case when cer=0 then p.saldocapital else 0 end) as 'capvig'  
,sum(case when cer=1 then p.saldocapital else 0 end) as 'capven'  
,sum(case when cer=0 and d.ciclo=1  then 1 else 0 end) as 'credvig1'  
,sum(case when cer=1 and d.ciclo=1 then 1 else 0 end) as 'credven1'  
,sum(case when cer=0 and d.ciclo=1 then p.saldocapital else 0 end) as 'capvig1'  
,sum(case when cer=1 and d.ciclo=1 then p.saldocapital else 0 end) as 'capven1'  
,sum(case when cer=0 and d.ciclo=2  then 1 else 0 end) as 'credvig2'  
,sum(case when cer=1 and d.ciclo=2 then 1 else 0 end) as 'credven2'  
,sum(case when cer=0 and d.ciclo=2 then p.saldocapital else 0 end) as 'capvig2'  
,sum(case when cer=1 and d.ciclo=2 then p.saldocapital else 0 end) as 'capven2'  
,sum(case when cer=0 and d.ciclo>=3 and d.ciclo<=4  then 1 else 0 end) as 'credvig3_4'  
,sum(case when cer=1 and d.ciclo>=3 and d.ciclo<=4 then 1 else 0 end) as 'credven3_4'  
,sum(case when cer=0 and d.ciclo>=3 and d.ciclo<=4 then p.saldocapital else 0 end) as 'capvig3_4'  
,sum(case when cer=1 and d.ciclo>=3 and d.ciclo<=4 then p.saldocapital else 0 end) as 'capven3_4'  
,sum(case when cer=0 and d.ciclo>=5 and d.ciclo<=6  then 1 else 0 end) as 'credvig5_6'  
,sum(case when cer=1 and d.ciclo>=5 and d.ciclo<=6 then 1 else 0 end) as 'credven5_6'  
,sum(case when cer=0 and d.ciclo>=5 and d.ciclo<=6 then p.saldocapital else 0 end) as 'capvig5_6'  
,sum(case when cer=1 and d.ciclo>=5 and d.ciclo<=6 then p.saldocapital else 0 end) as 'capven5_6'  
,sum(case when cer=0 and d.ciclo>=7  then 1 else 0 end) as 'credvig7'  
,sum(case when cer=1 and d.ciclo>=7 then 1 else 0 end) as 'credven7'  
,sum(case when cer=0 and d.ciclo>=7 then p.saldocapital else 0 end) as 'capvig7'  
,sum(case when cer=1 and d.ciclo>=7 then p.saldocapital else 0 end) as 'capven7'  
into #tcsCierremesMiio  
from tcsCierremesMiio p with(nolock)  
left outer join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo  
group by dbo.fdufechaaperiodo(fecha)   
order by  dbo.fdufechaaperiodo(fecha)    
  
  
  
select periodo  
,credvig  
,credven  
,capvig  
,capven  
,'Total' as ciclo  
from #tcsCierremesMiio  
union  
select periodo  
,credvig1  
,credven1  
,capvig1  
,capven1  
,'1' as ciclo  
from #tcsCierremesMiio  
union  
select periodo  
,credvig2  
,credven2  
,capvig2  
,capven2  
,'2' as ciclo  
from #tcsCierremesMiio  
union  
select periodo  
,credvig3_4  
,credven3_4  
,capvig3_4  
,capven3_4  
,'3_4' as ciclo  
from #tcsCierremesMiio  
union  
select periodo  
,credvig5_6  
,credven5_6  
,capvig5_6  
,capven5_6  
,'5_6' as ciclo  
from #tcsCierremesMiio  
union  
select periodo  
,credvig7  
,credven7  
,capvig7  
,capven7  
,'7' as ciclo  
from #tcsCierremesMiio  
drop table #tcsCierremesMiio
GO