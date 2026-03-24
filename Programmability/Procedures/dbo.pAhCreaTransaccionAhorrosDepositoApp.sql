SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pAhCreaTransaccionAhorrosDepositoApp]
@CodCuenta varchar(20),
@MontoTotal money,
@CodCajero varchar(20),
@Observaciones varchar(200) 
AS
BEGIN
	exec [10.0.2.14].finmas.dbo.pAhCreaTransaccionAhorrosDepositoApp @CodCuenta,@MontoTotal,@CodCajero,@Observaciones
END
GO