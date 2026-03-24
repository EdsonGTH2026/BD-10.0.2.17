SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsABonoLiderRegionalDatos] @fecha smalldatetime, @codoficina varchar(300) AS  
  
SELECT * FROM tCsRptBonoliderregional
GO