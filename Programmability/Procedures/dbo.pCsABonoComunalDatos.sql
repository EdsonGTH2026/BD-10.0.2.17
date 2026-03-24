SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsABonoComunalDatos] @fecha smalldatetime, @codoficina varchar(300) AS  
  
SELECT * FROM tCsRptBonoComunal
GO