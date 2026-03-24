SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboIntervaloAtrasoCA]

As 
SELECT     Reporte, Nombre
FROM         tCsPrReporte
WHERE     (IntervaloCartera = 1) 
GO