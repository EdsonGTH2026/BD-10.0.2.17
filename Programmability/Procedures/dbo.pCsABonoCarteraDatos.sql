SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsABonoCarteraDatos] @fecha smalldatetime, @codoficina varchar(300) AS

SELECT * FROM tCsRptBonoCartera
GO