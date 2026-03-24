SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[pCsCboFechaCorte]

As 
SELECT     '1' as Codigo, Nombre = 'Corte guardado'
Union
SELECT     '2' as Codigo, Nombre = 'Corte actual'
GO