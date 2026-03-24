SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsCboRegionales]
As
-- Noel - 2015 05 20
set nocount on

SELECT Zona, Regional = Nombre
FROM  tClZona
where activo=1

UNION

SELECT '0', 'Todas las Regionales'
ORDER BY Zona
GO