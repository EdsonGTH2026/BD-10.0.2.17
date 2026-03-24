SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboFechaCierre]

As 
SELECT     FechaConsolidacion + 1 AS Codigo, dbo.fduFechaATexto(FechaConsolidacion + 1, 'DD') +  '-'  + dbo.fduFechaATexto(FechaConsolidacion + 1, 'MM') +  '-' + dbo.fduFechaATexto(FechaConsolidacion + 1, 'AAAA') AS Fecha
FROM         vCsFechaConsolidacion
GO