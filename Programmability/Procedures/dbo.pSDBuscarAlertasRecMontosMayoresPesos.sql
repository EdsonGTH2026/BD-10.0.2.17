SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasRecMontosMayoresPesos](@FechaInicial DATETIME, @FechaFinal DATETIME, @TipoAlerta INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarAlertasRecMontosMayoresPesos] @FechaInicial, @FechaFinal, @TipoAlerta
END
GO