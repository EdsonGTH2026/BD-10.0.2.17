SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsCboNivelDiaAtraso]
As
SELECT     NivelDiaAtraso, Nombre
FROM         tCsPrNivelDiasAtraso
GO