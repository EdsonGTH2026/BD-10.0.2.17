SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsflujomiiocartera]   
as    
select  dbo.fdufechaaperiodo(fecha) periodo ,isnull(sum(SaldoCapital),0) as 'saldo' 
into #SaldoT 
from tcsCierremesMiio with(nolock) 
Group by dbo.fdufechaaperiodo(fecha) 
order by dbo.fdufechaaperiodo(fecha) ASC   

select  dbo.fdufechaaperiodo(fecha) periodo ,isnull(sum(SaldoCapital),0) as 'saldo' 
into #Saldocer 
from tcsCierremesMiio with(nolock) 
where cer=0 
Group by dbo.fdufechaaperiodo(fecha) 
order by dbo.fdufechaaperiodo(fecha) ASC   

select  dbo.fdufechaaperiodo(fecha) periodo ,isnull(sum(SaldoCapital),0) as 'saldo' 
into #Saldocertres 
from tcsCierremesMiio with(nolock) 
where cer=1  Group by dbo.fdufechaaperiodo(fecha) 
order by dbo.fdufechaaperiodo(fecha) ASC  

select  dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) periodo 
,isnull(sum(SaldoCapital),0) as 'saldo' 
into #Saldocerunion 
from tcsCierremesMiio with(nolock) 
where cer=1 
Group by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) 
order by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) ASC  

select a.periodo, b.saldo-a.saldo as delta, b.saldo/a.saldo as pcsdelta 
into #delta 
from #Saldocerunion a with(nolock) 
inner join #Saldocertres b with(nolock) on  a.periodo=b.periodo  

select t.periodo 
,t.saldo as 'Total Capital' 
,c.saldo as 'CeR 0 a 3' 
,r.saldo as 'CeR +3' 
,d.delta as 'Delta CeR+3 $' 
,100*(d.pcsdelta-1) as '$Delta CeR+3 $' 
,100*d.delta/c.saldo as 'deltavscart' 
from  #SaldoT t with(nolock)
inner join #Saldocer c with(nolock)on t.periodo=c.periodo 
inner join #Saldocertres r with(nolock)on t.periodo=r.periodo 
left outer join #delta d with(nolock)on t.periodo=d.periodo      

drop table  #SaldoT 
drop table #Saldocer  
drop table #Saldocertres 
drop table #delta 
drop table #Saldocerunion  
GO