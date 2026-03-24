SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsCboEncargado]
As
SELECT     Encargado AS Codigo, Encargado AS Nombre
FROM         tCsProyectoRescate
WHERE     (Activo = 1)
GO