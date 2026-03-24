SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--EXEC pCsCaRptMoraVsCTxProd '20130831'
--DROP PROC pCsCaRptMoraVsCTxProd
CREATE PROCEDURE [dbo].[pCsCaRptMoraVsCTxProd]
               ( @Fecha SMALLDATETIME )
AS  
--declare @Fecha smalldatetime  
    --set @Fecha = '20130831'  

  DECLARE @CT NUMERIC(16,2)
   SELECT @CT = SUM(d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido)
     FROM tCsCartera c WITH(NOLOCK)  
    INNER JOIN tcscarteradet d WITH(NOLOCK) ON c.fecha = d.fecha AND c.codprestamo = d.codprestamo  
    WHERE c.fecha   = @Fecha 
      AND c.cartera = 'ACTIVA'
  --PRINT @CT
  
SELECT c.CodProducto,
       @CT CT,
       (case when c.estado='VENCIDO'
             then d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido  
             else case when c.nrodiasatraso>0   
                       then d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido 
                       else 0 
                       end  --saldomora 
             end)/@CT saldo      
       ,p.NombreProdCorto  
  INTO #CT       
  FROM tCsCartera c WITH(NOLOCK)  
 INNER JOIN tcscarteradet d WITH(NOLOCK) ON c.fecha       = d.fecha AND c.codprestamo = d.codprestamo  
 INNER JOIN tcaproducto   p WITH(NOLOCK) ON c.codproducto = p.codproducto  
 WHERE c.fecha = @Fecha 
   AND c.cartera='ACTIVA'

SELECT CodProducto, CT, sum(Saldo) saldo, NombreProdCorto
  FROM #CT
 --WHERE CodProducto <> '163'
 GROUP BY CodProducto, CT, NombreProdCorto  
 ORDER BY saldo DESC
 
  DROP TABLE #CT   
   
GO