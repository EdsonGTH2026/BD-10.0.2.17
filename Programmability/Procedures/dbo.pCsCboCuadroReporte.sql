SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[pCsCboCuadroReporte]

As 
SELECT     '1' as Codigo, Nombre = 'Detalle'
Union
SELECT     '2' as Codigo, Nombre = 'Resumen'
GO