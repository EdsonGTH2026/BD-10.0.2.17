SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pOpProdAnalistaTiempoRevision
create procedure [dbo].[pOpProdAnalistaTiempoRevision] @fecini smalldatetime,@fecfin smalldatetime
as
	exec [ConsolidadoProduc].dbo.pOpProdAnalistaTiempoRevision @fecini,@fecfin
GO