SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsCboOficinas2]
As
-- Noel - 2015 05 19
set nocount on

SELECT CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + NomOficina NomOficina
FROM   tClOficinas
where codoficina<100
UNION

SELECT '0', '00 Todas las Oficinas'
ORDER BY NomOficina
GO