SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsCboClaseCartera]

As 
SELECT     *
FROM         tCaClClaseCartera
UNION
SELECT     Cartera = 'TODAS', Descripcion = 'TODAS'
GO