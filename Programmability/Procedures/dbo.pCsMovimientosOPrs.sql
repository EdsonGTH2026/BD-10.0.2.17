SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsMovimientosOPrs] @fecha smalldatetime
as
	truncate table tCsAMovimientoOPRs

	insert into tCsAMovimientoOPRs
	exec [10.0.2.14].finmas.dbo.pCsMovimientosOPrs @fecha
GO