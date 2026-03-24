SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCboFechaActiva] AS
SELECT DISTINCT Fecha
FROM         tCsCartera
WHERE     (Fecha >=
                          (SELECT     DATEADD([day], - 1, CAST(dbo.fduFechaATexto(FechaConsolidacion, 'AAAAMM') + '01' AS SmallDateTime)) AS Periodo
                            FROM          vCsFechaConsolidacion))
GO