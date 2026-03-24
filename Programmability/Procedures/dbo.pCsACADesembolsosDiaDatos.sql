SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsACADesembolsosDiaDatos]
               ( @fecha      smalldatetime, @codoficina varchar(1))
AS
SELECT * FROM tCsRptDesembolsosDia
GO