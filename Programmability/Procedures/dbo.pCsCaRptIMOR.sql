SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsCaRptIMOR
--EXEC pCsCaRptIMOR '20130831'
CREATE PROCEDURE [dbo].[pCsCaRptIMOR]
               ( @Fecha SMALLDATETIME )
AS

--declare @Fecha smalldatetime
--    set @Fecha = '20130831'

DECLARE @CT NUMERIC(16,2)
 SELECT @CT = SUM(d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido)
   FROM tCsCartera c WITH(NOLOCK)  
  INNER JOIN tcscarteradet d WITH(NOLOCK) ON c.fecha = d.fecha AND c.codprestamo = d.codprestamo  
  WHERE c.fecha   = @Fecha 
    AND c.cartera = 'ACTIVA'

 SELECT c.CodOficina, o.NomOficina Agencia,
        CASE WHEN z.Zona IS NULL THEN 'Z06' ELSE z.Zona END Zona, CASE WHEN z.Nombre IS NULL THEN 'Cerrada' ELSE z.Nombre END Region,  
        c.CodProducto, p.NombreProdCorto Producto,  
        SUM(cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) CT,
        SUM(CASE WHEN c.Estado = 'VENCIDO'
             THEN Case When c.NroDiasAtraso > 90
                       Then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
                      Else 0
                       End
              ELSE 0
              END)SaldoVencidoMayor90Dias
   INTO #CTIMOR            
   FROM tCsCartera c WITH(NOLOCK)
  INNER JOIN tcscarteradet cd WITH(NOLOCK) ON c.fecha       = cd.fecha AND c.codprestamo = cd.codprestamo
  INNER JOIN tcloficinas    o WITH(NOLOCK) ON c.codoficina  = o.codoficina
  INNER JOIN tcaproducto    p WITH(NOLOCK) ON c.codproducto = p.codproducto  
  LEFT OUTER JOIN tClZona   z WITH(NOLOCK) ON o.Zona       = z.Zona
  WHERE c.Fecha   = @Fecha--'20130831' 
    AND c.cartera = 'ACTIVA'
  GROUP BY c.CodOficina, o.NomOficina, z.Zona, z.Nombre, c.CodProducto, p.NombreProdCorto 
 --ORDER BY CodProducto--z.Zona
             
SELECT @Fecha FechaInf, Zona +' '+Region Region,	
       CodOficina+' '+ Agencia Sucursal,
       Producto,	
       CT,	SaldoVencidoMayor90Dias, 
       (SaldoVencidoMayor90Dias/@CT) IMOR,
       Convert(numeric(16,3),(SaldoVencidoMayor90Dias/@CT)*100) PorcIMOR
 FROM #CTIMOR             
ORDER BY Zona, Agencia, CodProducto

/*
Calculo del IMOR, que es cartera mayor a 90 días de vencida entre saldo cartera total, 
que se pueda visualizar por agencia, 
por región, por producto 
y por cartera total.
*/

             
GO