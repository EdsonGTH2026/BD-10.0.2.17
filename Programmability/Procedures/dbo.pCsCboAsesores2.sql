SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsCboAsesores2]
As
-- Noel - 2015 05 20
set nocount on

SELECT CodAsesor, NomAsesor
FROM   tCsAsesores
WHERE  Activo = '1'

UNION

SELECT '0', ' Todos los Asesores'
ORDER BY NomAsesor
GO