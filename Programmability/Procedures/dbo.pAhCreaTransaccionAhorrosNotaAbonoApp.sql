SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pAhCreaTransaccionAhorrosNotaAbonoApp]
@CodCuenta varchar(20),
@MontoTotal money,
@CodCajero varchar(20),
@Observaciones varchar(200),
@CodMotivo INTEGER = 0,
@FechaOperacion smalldatetime = null 
AS
BEGIN
	exec [10.0.2.14].finmas.dbo.pAhCreaTransaccionAhorrosNotaAbonoApp @CodCuenta,@MontoTotal,@CodCajero,@Observaciones,@CodMotivo,@FechaOperacion
END

GO