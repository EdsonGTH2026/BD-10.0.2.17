SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pOpProdAnalistaTiempo
create procedure [dbo].[pOpProdAnalistaTiempo] @fecini smalldatetime,@fecfin smalldatetime
as
	exec [ConsolidadoProduc].dbo.pOpProdAnalistaTiempo @fecini,@fecfin
GO