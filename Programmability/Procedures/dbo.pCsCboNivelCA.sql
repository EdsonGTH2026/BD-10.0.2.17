SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboNivelCA]

As 
SELECT     Nivel AS Codigo, Cartera AS Nombre
FROM         tCsPrNivel
WHERE     (Activo = 1) AND (Cartera IS NOT NULL) AND (RTRIM(LTRIM(Cartera)) <> '')
GO