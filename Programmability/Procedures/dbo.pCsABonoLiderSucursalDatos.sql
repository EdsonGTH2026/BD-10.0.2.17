SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsABonoLiderSucursalDatos] @fecha smalldatetime, @codoficina varchar(300) AS  
  
SELECT * FROM tCsRptBonolidersucursal
GO