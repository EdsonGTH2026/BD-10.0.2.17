SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pOpProdAnalistaTiempoMesa
create procedure [dbo].[pOpProdAnalistaTiempoMesa] @fecini smalldatetime,@fecfin smalldatetime
as
	exec [ConsolidadoProduc].dbo.pOpProdAnalistaTiempoMesa @fecini,@fecfin
GO