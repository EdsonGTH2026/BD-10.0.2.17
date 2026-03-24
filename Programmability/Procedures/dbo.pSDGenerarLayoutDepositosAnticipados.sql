SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDGenerarLayoutDepositosAnticipados](@FechaInicial DATETIME, @FechaFinal DATETIME, @TipoAlerta INT,
														   @CodigoLocalidad VARCHAR(8), @TipoOperacion VARCHAR(2))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDGenerarLayoutDepositosAnticipados] @FechaInicial, @FechaFinal, @TipoAlerta, @CodigoLocalidad, @TipoOperacion
END
GO