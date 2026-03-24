SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboObservacionCliente]
As 
SELECT DISTINCT tCsClientesObservaciones.Observacion, tCsClClientesObservaciones.Nombre
FROM         vCsFechaConsolidacion INNER JOIN
                      tCsClientesObservaciones ON vCsFechaConsolidacion.FechaConsolidacion = tCsClientesObservaciones.Fecha INNER JOIN
                      tCsClClientesObservaciones ON tCsClientesObservaciones.Observacion = tCsClClientesObservaciones.Observacion
WHERE     (tCsClClientesObservaciones.Activo = 1)
UNION 
Select Observacion = 'TODAS', Nombre = 'Todas las Observaciones'
GO