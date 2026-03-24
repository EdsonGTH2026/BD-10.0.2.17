SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext cosechamiiotab1
    
CREATE procedure [dbo].[cosechamiiotab1]     
as      
    
select  dbo.fdufechaaperiodo(p.desembolso) periodo      
,sum(p.monto) as 'colocacion'      
,count(p.codprestamo) as 'nro'      
into #grafanamiio      
from tcsgrafanamiio p with(nolock)     
inner join [10.0.2.14].[finmas].[dbo].[tcaprestamos] c on c.CodPrestamo = p.CodPrestamo and c.estado<>'ANULADO'  
group by dbo.fdufechaaperiodo(p.desembolso)       
order by  dbo.fdufechaaperiodo(p.desembolso)       
      
  
select dbo.fdufechaaperiodo(t.desembolso) periodo      
--,sum(case when  t.NroDiasAtraso < 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cer3'    
,sum(case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso < 3 then  cd.saldocapital  else 0 end else 0 end)  as 'cer3'   
--,sum(case when  t.NroDiasAtraso < 3 then 1 else 0 end ) as 'nrocer3'     
,sum(case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso < 3 then  1  else 0 end else 0 end)  as 'nrocer3'   
   
--,sum(case when  t.NroDiasAtraso >= 3 then isnull(t.SaldoCapital,0) else 0 end ) as 'cermay3'      
,sum(case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso >= 3 then  cd.saldocapital  else 0 end else 0 end)  as 'cermay3'   
  
--,sum(case when  t.NroDiasAtraso >= 3 then 1 else 0 end ) as 'nrocermay3'    
,sum(case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso >= 3 then  1  else 0 end else 0 end)  as 'nrocermay3'   
  
into #carteraactivamiio  ---select top 10*    
from carteraactivamiio  t with(nolock)   
inner join tCsCartera c with(nolock) on c.codprestamo=t.codprestamo and c.fecha=t.fecha  
inner join tcscarteradet cd with(nolock) on cd.fecha=c.fecha and cd.codprestamo=c.codprestamo and cd.codusuario=c.codusuario 
inner join tcsCicloMIIO_230920 clc with(nolock) on t.codprestamo=clc.codprestamo 
where dbo.fdufechaaperiodo(t.desembolso)>='202210'
and t.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by dbo.fdufechaaperiodo(t.desembolso)       
order by  dbo.fdufechaaperiodo(t.desembolso)       
      
      
      
select       
a.periodo      
,colocacion      
,nro      
,isnull(colocacion,0)-isnull(cer3,0)-isnull(cermay3,0) as 'capitalpagado'      
,case when isnull(colocacion,0)=0 then 0 else (isnull(colocacion,0)-isnull(cer3,0)-isnull(cermay3,0))*100/colocacion end as 'cap%'      
,cer3 as 'capitalvigente'      
,case when isnull(colocacion,0)=0 then 0 else isnull(cer3,0)*100/colocacion end as '%capitalvigente'      
,nrocer3      
,case when isnull(nro,0)=0 then 0 else cast(isnull(nrocer3,0) as money)*100/nro end as 'nrocre3%'      
,cermay3 as 'cer3may'      
,case when isnull(colocacion,0)=0 then 0 else isnull(cermay3,0)*100/colocacion end as '%cer3may'      
,nrocermay3      
,case when isnull(nro,0)=0 then 0 else cast(isnull(nrocermay3,0) as money)*100/nro end as 'nrocre3may%'      
from #grafanamiio g      
inner join  #carteraactivamiio a on a.periodo=g.periodo      
      
      
drop table #grafanamiio      
drop table #carteraactivamiio
GO