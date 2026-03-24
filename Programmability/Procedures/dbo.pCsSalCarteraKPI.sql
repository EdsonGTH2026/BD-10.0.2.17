SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---- Optimizacion del sp 2023.10.17 ZCCU

CREATE procedure [dbo].[pCsSalCarteraKPI] @fecha smalldatetime    
as    
set nocount on  

--declare @fecha smalldatetime    
--set @fecha='20231016'    
   
--declare  @sal table(codoficina varchar(4)  
--     --,nomoficina varchar(30)  
--     --,region varchar(50)    
--     ,saldocapital money  
--     ,vigente0a30 money  
--     ,atraso31a89 money  
--     ,vencido90 money  
--     ,saldoCastigado money  
--     ,carteraVencida money  
--     ,nroPtmosVig int  
--    )     
--insert into @sal    
select c.codoficina codoficina  
--,o.nomoficina nomoficina   
--,z.nombre region  
,sum(c.saldocapital) saldocapital   
,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then c.saldocapital else 0 end)vigente0a30  
,sum(case when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then c.saldocapital else 0 end)atraso31a89  
,sum(case when c.nrodiasatraso>=90  then c.saldocapital else 0 end)vencido90  
,sum(case when c.estado='CASTIGADO'  then c.saldocapital else 0 end)saldoCastigado  
,sum(case when c.nrodiasatraso>=31 then c.saldocapital else 0 end)carteraVencida  
,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 1 else 0 end)nroPtmosVig  
from tcscartera c with(nolock)    
--inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
--inner join tclzona z on z.zona=o.zona  
where c.fecha=@fecha 
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    
and c.codoficina not in('97','231','230','999')  
and cartera='ACTIVA' 
group by c.codoficina--,o.nomoficina--,z.nombre   
--order by o.nomoficina   
  
  
  
  
GO