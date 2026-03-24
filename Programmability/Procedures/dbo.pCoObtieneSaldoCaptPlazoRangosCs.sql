SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[pCoObtieneSaldoCaptPlazoRangosCs](
		 @Fecha as smalldatetime,
		 @TCUDIS as money,
		 @RangoInf as money,
		 @RangoSup as money,
		 @Saldo As money out,
		 @Nro As int out
) 

with encryption
AS
set nocount on 

declare @SaldoDepoVista as money
declare @SaldoDepoVistaC as int
declare @SaldoAho as money
declare @SaldoAhoInt as money
declare @SaldoAhoC as int
declare @SaldoReti as money
declare @SaldoRetiInt as money
declare @SaldoRetiC as int

declare @SaldoPrestFin as money
declare @SaldoPrestFinC as int 
declare @SaldoPrestFinInt as money

declare @FechaVenc as smalldatetime
DECLARE @FechaCierre as DateTime
DECLARE @FechaProceso as DateTime
DECLARE @FechaProm smalldatetime
DECLARE @Mes int
DECLARE @Anio int

	IF Month(@Fecha)= 1 
		BEGIN
			SET @Mes = 12
			SET @Anio = Year(@Fecha) -1
		END
	ELSE
		BEGIN
			SET @Mes = Month(@Fecha) -1
			SET @Anio = Year(@Fecha)
		END
	
-- 	SET @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	
-- 	SET @FechaProceso = DateAdd(Month,1,@FechaProm) --primer dia de mes despues del cierre
-- 	SET @FechaCierre = DateAdd(Day, -1, @FechaProceso) --fecha de cierre, ultimo dia de mes

	SET @FechaProm = @Fecha
	SET @FechaProceso = @Fecha
	SET @FechaCierre = @Fecha

	set @RangoInf = @RangoInf --* @TCUDIS
	set @RangoSup = @RangoSup --* @TCUDIS) - 0.0010

	set @SaldoDepoVista = 0
	set @SaldoDepoVistaC = 0

	-- Obtiene los depositos a la vista
	select @SaldoDepoVista = isnull( sum(MontoGiro), 0 ), @SaldoDepoVistaC = isnull( count(MontoGiro), 0)
	from tCsGiros
	where FechaPago is null
	and TipoGiro = 'R'
	and (EstadoGiro = 'P' or EstadoGiro = 'U')
	and MontoGiro between @RangoInf and @RangoSup

	select @SaldoDepoVista = @SaldoDepoVista + isnull( sum(MontoGiro), 0 ), @SaldoDepoVistaC = @SaldoDepoVistaC + isnull( count(MontoGiro), 0)
	from tCsGiros
	where FechaPago <= @FechaCierre
	and TipoGiro = 'R'
	and EstadoGiro = 'G'
	and MontoGiro between @RangoInf and @RangoSup

	set @SaldoAho = 0
	set @SaldoAhoC = 0
	set @SaldoAhoInt = 0

	-- Obtiene los depositos de ahorro
	select @SaldoAho = isnull( sum(SaldoCuenta), 0 ), @SaldoAhoInt = isnull( sum(IntAcumulado), 0 ), @SaldoAhoC = isnull( count(SaldoCuenta), 0)
	from tCsAhorros
	where CodProducto not like '2%'
	and IdEstadoCta <> 'CC'
	and Fecha = @FechaCierre
	and SaldoCuenta between @RangoInf and @RangoSup

	set @SaldoReti = 0
	set @SaldoRetiC = 0

	-- Obtiene los depositos retirables
	select @SaldoReti = isnull( sum(SaldoCuenta), 0 ), @SaldoRetiC = isnull( count(SaldoCuenta), 0)
	from tCsAhorros
	where CodProducto like '2%'
	and (FechaCierre <= @FechaCierre or FechaCierre is null)
	and SaldoCuenta between @RangoInf and @RangoSup
	and FechaVencimiento >= @FechaCierre
	AND CodCuenta + FraccionCta + Cast(Renovado as VArChar(100)) IN 
						(SELECT CodCuenta + FraccionCta + Cast(Renovado As VarChar(100))
						 FROM tCsAhorros
						 WHERE Fecha = @FechaCierre AND CodProducto like '2%'
						       AND IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV')


	-- Intereses
	select @SaldoRetiInt = isnull( sum(IntAcumulado), 0)
	from tCsAhorros
	where CodProducto like '2%'
	      and Fecha = @FechaCierre
	      and idEstadoCta <> 'CC'AND IdEstadoCta <> 'CV'
	      and SaldoCuenta between @RangoInf and @RangoSup

	-- Obtiene los datos de financiamiento
	set @SaldoPrestFin = 0
	set @SaldoPrestFinInt = 0
	set @SaldoPrestFinC = 0

	select @SaldoPrestFin = isnull(sum(MontoCapital) ,0), @SaldoPrestFinC = isnull(count(MontoCapital) ,0 )
	from tCsPrestFin P, tCsPrestFinDet D
	where P.CodPrestFin = D.CodPrestFin
	and P.Estado = '1'
	and P.Categoria = '2'
	and MontoCapital between @RangoInf and @RangoSup
	and D.FechaVencimiento >= @FechaCierre

	select @SaldoPrestFinInt = isnull(sum(MontoInteres) ,0)
	from tCsPrestFin P, tCsPrestFinDet D
	where P.CodPrestFin = D.CodPrestFin
	and P.Estado = '1'
	and P.Categoria = '2'
	and MontoInteres between @RangoInf and @RangoSup
	and D.FechaVencimiento >= @FechaCierre	

	Set @Saldo = isnull(@SaldoDepoVista,0) + isnull(@SaldoAho,0) + isnull(@SaldoReti,0) + isnull(@SaldoPrestFin,0) + isnull(@SaldoAhoInt,0) + isnull(@SaldoRetiInt,0) + isnull(@SaldoPrestFinInt,0)
	Set @Nro = isnull(@SaldoDepoVistaC,0) + isnull(@SaldoAhoC,0) + isnull(@SaldoRetiC,0) + isnull(@SaldoPrestFinC,0)
	
	
GO