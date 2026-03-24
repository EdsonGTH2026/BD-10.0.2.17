SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCHCboOficinas] AS  
SELECT CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina  
  FROM tClOficinas 
  where codoficina<100 
ORDER BY NomOficina
GO