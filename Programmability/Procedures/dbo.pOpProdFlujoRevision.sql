SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pOpProdFlujoRevision] @fecha datetime
as
	exec [ConsolidadoProduc].dbo.pOpProdFlujoRevision @fecha
GO