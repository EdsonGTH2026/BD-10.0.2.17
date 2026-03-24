SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboIntervalo]

As 
SELECT     Intervalo, Nombre
FROM         tCsPrIntervalo

GO