SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsCaRptCTxRegion
--EXEC pCsCaRptCTxRegion '20130831'
CREATE PROCEDURE [dbo].[pCsCaRptCTxRegion]
               ( @Fecha SMALLDATETIME )
AS  
--declare @Fecha smalldatetime  
--    set @Fecha = '20130831'  
  
SELECT CASE WHEN z.Zona IS NULL THEN 'Z06' ELSE z.Zona END CodProducto, --Zona
       SUM(d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldo,  
       SUM((case when c.estado='VENCIDO'
             then d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido  
             else case when c.nrodiasatraso>0   
                       then d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido 
                       else 0 
                       end  
             end)) saldomora,
       CASE WHEN z.Nombre IS NULL THEN 'Cerrada' ELSE z.Nombre END NombreProdCorto--NombreZona  
  FROM tCsCartera c WITH(NOLOCK)  
 INNER JOIN tcscarteradet d WITH(NOLOCK) ON c.fecha = d.fecha AND c.codprestamo = d.codprestamo  
 INNER JOIN tClOficinas   o WITH(NOLOCK) ON c.CodOficina = o.CodOficina
 LEFT OUTER JOIN tClZona  z WITH(NOLOCK) ON o.Zona       = z.Zona
 --left outer join tClOficinas   o with(nolock) on c.CodOficina = o.CodOficina
 WHERE c.Fecha   = @Fecha
   AND c.cartera = 'ACTIVA'
 GROUP BY z.Zona, z.Nombre 
 ORDER BY Saldo desc, saldomora desc--CodProducto--z.Zona
 
 --select * from tClZona
 
 
 
 
GO