SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsACADesembolsosDia]
               ( @fecha      smalldatetime)
AS
truncate table tCsRptDesembolsosDia
insert into tCsRptDesembolsosDia
exec [10.0.2.14].FinMas.dbo.pCsCADesembolsosDia @fecha
GO