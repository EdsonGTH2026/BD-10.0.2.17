SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsMovimientosOPrsDatos] @fecha smalldatetime,@codoficina varchar(1)
as
	select * from tCsAMovimientoOPRs
GO