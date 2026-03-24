SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pAhCreaTransaccionAhorrosRetiroApp]
@CodCuenta varchar(20),
@MontoTotal money,
@CodCajero varchar(20),
@Observaciones varchar(200)
as 
begin
	exec [10.0.2.14].finmas.dbo.pAhCreaTransaccionAhorrosRetiroApp @CodCuenta,@MontoTotal,@CodCajero,@Observaciones
end
GO