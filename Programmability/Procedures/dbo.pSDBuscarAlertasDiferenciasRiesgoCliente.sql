SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasDiferenciasRiesgoCliente](@FechaInicial DATETIME, @FechaFinal DATETIME, @Top500 BIT = 0)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarAlertasDiferenciasRiesgoCliente] @FechaInicial, @FechaFinal, @Top500
END
GO