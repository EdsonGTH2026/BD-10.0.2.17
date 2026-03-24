SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboNivelAH]

As 
SELECT     Nivel AS Codigo, Ahorro AS Nombre
FROM         tCsPrNivel
WHERE     (Activo = 1) AND (Ahorro IS NOT NULL) AND (RTRIM(LTRIM(Ahorro)) <> '')
GO