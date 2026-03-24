SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsABonoCarteraV2Datos] @fecha smalldatetime, @codoficina varchar(300) AS  
  
SELECT * FROM tCsRptBonoCarteraV2
where fecha=@fecha and tipocalculo=@codoficina
GO