SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pOpProdTiempoProm
create procedure [dbo].[pOpProdTiempoProm] @fecini smalldatetime,@fecfin smalldatetime
as
	exec [ConsolidadoProduc].dbo.pOpProdTiempoProm @fecini,@fecfin
GO