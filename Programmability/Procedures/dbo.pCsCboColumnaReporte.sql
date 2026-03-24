SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboColumnaReporte]
As 
SELECT     Identificador
FROM         tCsPrReportesAnexos
WHERE     (Reporte = 'CA01')
GO