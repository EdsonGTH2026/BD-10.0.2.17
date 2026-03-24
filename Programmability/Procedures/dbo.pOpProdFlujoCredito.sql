SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pOpProdFlujoCredito] @fecha datetime
as
	exec [ConsolidadoProduc].dbo.pOpProdFlujoCredito @fecha
GO