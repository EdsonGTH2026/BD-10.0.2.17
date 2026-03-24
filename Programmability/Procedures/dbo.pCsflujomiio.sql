SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext pCsflujomiio
CREATE procedure [dbo].[pCsflujomiio]  
as     
  
select dbo.fdufechaaperiodo(fecha) periodo  
,sum(p.interes+p.moratorios2) as 'totalinteres'  
into #tcscobranzamiio  
from tcscobranzamiio p with(nolock)  
inner join tcsCicloMIIO_230920 d with(nolock)  on d.codprestamo=p.codprestamo  
group by dbo.fdufechaaperiodo(fecha)   
order by  dbo.fdufechaaperiodo(fecha)   
    
select  dbo.fdufechaaperiodo(fecha) periodo 
,isnull(sum(SaldoCapital),0) as 'saldo'  
into #Saldocertres 
from tcsCierremesMiio with(nolock)   
where cer=1  
Group by dbo.fdufechaaperiodo(fecha)   
order by dbo.fdufechaaperiodo(fecha) ASC    
  
select  dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) periodo 
,isnull(sum(SaldoCapital),0) as 'saldo'   
into #Saldocerunion 
from tcsCierremesMiio with(nolock)   
where cer=1 
Group by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime))   
order by dbo.fdufechaaperiodo(cast(dbo.fdufechaaperiodo(DATEADD(m,1,fecha))+'01' as smalldatetime)) ASC     
  
  
select a.periodo, b.saldo-a.saldo as delta
, b.saldo/a.saldo as pcsdelta   
into #delta 
from #Saldocerunion a   
inner join #Saldocertres b with(nolock)  on a.periodo=b.periodo    
  
select c.periodo,d.delta,c.totalinteres,c.totalinteres-d.delta as 'flujo' 
from  #tcscobranzamiio c with(nolock)  
inner join #delta d with(nolock) on d.periodo=c.periodo    

drop table #tcscobranzamiio 
drop table #delta 
drop table #Saldocertres 
drop table #Saldocerunion 
GO