SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCboPrReportes] AS

SELECT     Reporte, Reporte + ' [' + Nombre + ']' AS nombre
FROM         tCsPrReporte
WHERE     (Activo = 1)
GO