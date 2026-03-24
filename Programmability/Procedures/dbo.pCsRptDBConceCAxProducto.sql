SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT PCSRPTDBCONCECAXPRODUCTO
--DROP PROC pCsRptDBConceCAxProducto
--EXEC pCsRptDBConceCAxProducto '20130831'
CREATE PROCEDURE [dbo].[pCsRptDBConceCAxProducto] @fecha smalldatetime AS  
--declare @fecha smalldatetime  
--set @fecha='20130831'  
  
SELECT c.CodProducto,d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido saldo  
       ,case when c.estado='VENCIDO' then  
       d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido  
       else  
       case when c.nrodiasatraso>0   
       then d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido else 0 end  
       end saldomora  
       ,p.NombreProdCorto  
  into #TC       
  FROM tCsCartera c with(nolock)  
 inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
 inner join tcaproducto p with(nolock) on p.codproducto=c.codproducto  
 where c.fecha=@fecha
   and c.cartera='ACTIVA'
   
SELECT CodProducto, SUM(Saldo) saldo, SUM(saldomora) saldomora, NombreProdCorto
  FROM #TC
 GROUP BY CodProducto, NombreProdCorto  
 ORDER BY saldo desc, saldomora desc
 
  DROP TABLE  #TC
GO