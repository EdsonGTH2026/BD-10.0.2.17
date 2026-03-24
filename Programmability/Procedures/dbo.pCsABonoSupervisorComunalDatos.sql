SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsABonoSupervisorComunalDatos] @fecha smalldatetime, @codoficina varchar(300) AS  
  
SELECT * FROM tCsRptBonoSupervidorComunal
GO