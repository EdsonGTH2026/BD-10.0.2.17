SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCHCboEdoCivil] AS  
SELECT CodEstadoCivil, EstadoCivil
  FROM tUsClEstadoCivil  
ORDER BY CodEstadoCivil
GO