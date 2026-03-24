SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptKPINacionaltbl6] @fecha smalldatetime  
as     
set nocount on   

  
declare @fecosecha smalldatetime --A PARTIR DE QUE FECHA QUIERES EVALUAR COSECHAS  
set @fecosecha=dbo.fdufechaaperiodo(dateadd(month,-11,@fecha))+'01'  
  

------------------- DETERIORO  
 declare @ptmos table(codprestamo varchar(20))  
 insert into @ptmos  
 select distinct codprestamo  
 from tcspadroncarteradet pd with(nolock)  
 where pd.desembolso>=@fecosecha -- A PARTIR DE QUE FECHA COSECHAS SE EVALUA  
 and pd.desembolso<=@fecha       -- fecha corte  
 and pd.codoficina not in('97','230','231','98','999')   
 and codprestamo not in (select codprestamo from tCsCarteraAlta)  
   
declare @cos table (ID int IDENTITY(1,1),cosecha varchar(6))  
insert into @cos(cosecha)   
select DISTINCT dbo.fdufechaaperiodo(pd.desembolso)cosecha  
FROM tcspadroncarteradet pd with(nolock)  
where pd.codprestamo in(select codprestamo from @ptmos)  
order by dbo.fdufechaaperiodo(pd.desembolso)  
  
  
/*--- Mostrar un periodo de  12 cosechas */  
  
declare @deterioro table (colocacion money  
      ,recuperado money  
      ,cosecha varchar(6)  
      ,D0saldo money  
      ,D0a15saldo money  
      ,D16saldo money  
      ,Castigadosaldo money)  
insert into @deterioro       
select sum(montodesembolso) montodesembolso  
 ,sum(montodesembolso)-sum(D0saldo)-sum(Castigadosaldo) recuperado  
 ,cosecha cosecha  
 ,sum(D0saldo)D0saldo  
 ,sum(D0a15saldo)D0a15saldo  
 ,sum(D16saldo)D16saldo  
 ,sum(Castigadosaldo)Castigadosaldo  
 from (  
   SELECT o.zona,  
  o.codoficina ,  
  isnull(cd.saldocapital,0) saldocapital  
   ,pd.monto montodesembolso  
   ,dbo.fdufechaaperiodo(pd.Desembolso) cosecha    
 ,case when c.cartera= 'CASTIGADA' then   cd.saldocapital   else 0 end Castigadosaldo  
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=16 then  cd.saldocapital  else 0 end else 0 end D16saldo  
    ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=15  then  cd.saldocapital  else 0 end else 0 end D0a15saldo  
  ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 then cd.saldocapital  else 0 end else 0 end D0saldo  
   FROM tcspadroncarteradet pd with(nolock)  
   left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
   left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha  
   inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina  
   where pd.codprestamo in(select codprestamo from @ptmos)   
 ) a   
   group by cosecha  
   order by cosecha  

--TOTALES NACIONALES
declare @detnacional table (cosecha varchar(6)
      ,colocacion money  
      ,recuperado money
      ,porRecupera money    
      ,Deterioro0a15 money  
      ,Deterioro16 money )  
insert into @detnacional
select cosecha
      ,colocacion
      ,recuperado
      ,case when recuperado = 0 then 0 else (recuperado/colocacion)*100 end 
      ,case when D0a15saldo = 0 then 0 else (D0a15saldo/colocacion)*100 end
      ,case when (D16saldo+Castigadosaldo) = 0 then 0 else ((D16saldo+Castigadosaldo)/colocacion)*100 end 
from @deterioro
select * from @detnacional 

GO