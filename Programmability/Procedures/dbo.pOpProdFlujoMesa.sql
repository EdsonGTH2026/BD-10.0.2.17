SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pOpProdFlujoMesa] @fecha datetime
as
	exec [ConsolidadoProduc].dbo.pOpProdFlujoMesa @fecha
GO