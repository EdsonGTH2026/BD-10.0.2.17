SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsAOpeMay30milDatos] @fecha smalldatetime,@codoficina varchar(300)
AS  
	SELECT * FROM tCsRptOpeMay30mil
GO