SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasDepositosEfectivo](@FechaInicial DATETIME, @FechaFinal DATETIME, @TipoAlerta INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarAlertasDepositosEfectivo] @FechaInicial, @FechaFinal, @TipoAlerta
END
GO