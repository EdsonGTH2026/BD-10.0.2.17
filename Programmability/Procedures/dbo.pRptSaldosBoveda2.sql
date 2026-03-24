SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRptSaldosBoveda2](@Fecha smalldatetime) as
BEGIN
	exec [10.0.2.14].Finmas.dbo.pTcRptSaldosBovedaDetalle @Fecha
END

GO