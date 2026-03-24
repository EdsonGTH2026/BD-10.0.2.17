SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasRiesgoCliente](@FechaInicial DATETIME, @FechaFinal DATETIME, @TipoAlerta INT, @Riesgo VARCHAR(5), 
													  @NombreCliente VARCHAR(120), @TipoProceso VARCHAR(2), @Top500 BIT = 0)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarAlertasRiesgoCliente] @FechaInicial, @FechaFinal, @TipoAlerta, @Riesgo, @NombreCliente, @TipoProceso, @Top500
END
GO