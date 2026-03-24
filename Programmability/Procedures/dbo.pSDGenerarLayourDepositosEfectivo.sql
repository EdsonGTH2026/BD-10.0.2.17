SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDGenerarLayourDepositosEfectivo](@FechaInicial DATETIME, @FechaFinal DATETIME, @TipoAlerta INT,
														   @CodigoLocalidad VARCHAR(8))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDGenerarLayourDepositosEfectivo] @FechaInicial, @FechaFinal, @TipoAlerta, @CodigoLocalidad
END
GO