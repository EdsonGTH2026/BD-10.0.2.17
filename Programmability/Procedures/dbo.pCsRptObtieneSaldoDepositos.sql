SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptObtieneSaldoDepositos](
	@Fecha as smalldatetime
) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @DepMen90 as money
declare @DepMay90 as money

declare @FechaLimite as datetime,
	@FechaCns as datetime

	set @DepMen90 = 0
	set @DepMay90 = 0
	
	set @FechaLimite = dateadd (day, 90, @Fecha)	
	-- Obtiene los datos menores a 90
	select @DepMen90 = isnull( sum(SaldoCuenta),0)
	from tCsAhorros
	where CodProducto not like '2%'
	and IdEstadoCta <> 'CC' and Fecha = @Fecha

	select @DepMen90 = @DepMen90 + isnull( sum(SaldoCuenta),0)
	from tCsAhorros
	where CodProducto like '2%'
	and IdEstadoCta <> 'CC'
	and Plazo <= 90
	and FechaVencimiento >= @Fecha and Fecha = @Fecha

	select @DepMen90 = @DepMen90 + isnull(sum(MontoGiro), 0)
	from tCsGiros
	where (TipoGiro = 'O' or TipoGiro = 'R')
	and (EstadoGiro = 'D' or EstadoGiro = 'P')  and Fecha = @Fecha

	select @DepMay90 = isnull( sum(SaldoCuenta),0)
	from tCsAhorros
	where CodProducto like '2%'
	and IdEstadoCta <> 'CC'
	and Plazo > 90
	and FechaVencimiento >= @Fecha and Fecha = @Fecha

	select @DepMen90 as SaldoMen90, @DepMay90 as SaldoMay90

GO