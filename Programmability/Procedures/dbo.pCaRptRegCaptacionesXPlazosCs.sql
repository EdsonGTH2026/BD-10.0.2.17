SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCaRptRegCaptacionesXPlazosCs](
	         @Fecha as smalldatetime,
		 @TCUDIS as money
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

declare @Plazo1_7 as money
declare @Plazo1_7C as int
declare @Plazo8_1 as money
declare @Plazo8_1C as int
declare @Plazo1_3 as money
declare @Plazo1_3C as int
declare @Plazo3_6 as money
declare @Plazo3_6C as int
declare @Plazo6_12 as money
declare @Plazo6_12C as int
declare @Plazo12_24 as money
declare @Plazo12_24C as int
declare @Plazo24_99 as money
declare @Plazo24_99C as int

declare @Rango0_5 as money
declare @Rango0_5C as int
declare @Rango5_10 as money
declare @Rango5_10C as int
declare @Rango10_15 as money
declare @Rango10_15C as int
declare @Rango15_20 as money
declare @Rango15_20C as int
declare @Rango20_25 as money
declare @Rango20_25C as int
declare @Rango25_99 as money
declare @Rango25_99C as int
	
	------------ PLAZO DE 1 A 7 DIAS ------------------------

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
	
	set @SaldoDepoVista = 0
	set @SaldoDepoVistaC = 0

	-- Obtiene los depositos a la vista
	select @SaldoDepoVista = isnull( sum(MontoGiro), 0 ), @SaldoDepoVistaC = isnull( count(MontoGiro), 0)
	from tCsGiros
	where FechaPago is null
		and TipoGiro = 'R'
		and (EstadoGiro = 'P' or EstadoGiro = 'U')

	select @SaldoDepoVista = @SaldoDepoVista + isnull( sum(MontoGiro), 0 ), @SaldoDepoVistaC = @SaldoDepoVistaC + isnull( count(MontoGiro), 0)
	from tCsGiros
	where FechaPago <= @FechaCierre
		and TipoGiro = 'R'
		and EstadoGiro = 'G'

	set @SaldoAho = 0
	set @SaldoAhoC = 0
	set @SaldoAhoInt = 0

	-- Obtiene los depositos de ahorro
	select @SaldoAho = isnull( sum(SaldoCuenta), 0 ), @SaldoAhoInt = isnull( sum(IntAcumulado), 0 ), @SaldoAhoC = isnull( count(SaldoCuenta), 0)
	from tCsAhorros
	where CodProducto not like '2%'
	and IdEstadoCta <> 'CC'
	and Fecha = @FechaCierre

	set @FechaVenc = dateadd(day, 7, @Fecha)
	set @SaldoReti = 0
	set @SaldoRetiC = 0

	-- Obtiene los depositos retirables
	select @SaldoReti = isnull( sum(SaldoCuenta), 0 ), @SaldoRetiC = isnull( count(SaldoCuenta), 0)
	from tCsAhorros
	where CodProducto like '2%'
	and (FechaCierre <= @FechaCierre or FechaCierre is null)
	and FechaVencimiento between @Fecha and @FechaVenc
	AND Plazo <= 7
	AND IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV'

	-- Intereses
	SET @SaldoRetiInt = 0
	select @SaldoRetiInt = isnull( sum(IntAcumulado), 0)
	from tCsAhorros 
	where CodProducto like '2%'
	and fecha=@fecha
-- 	and (FechaCierre <= @FechaCierre or FechaCierre is null)
-- 	and FechaVencimiento between @Fecha and @FechaVenc
-- 	AND Plazo <= 7
	and IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV'

	-- Obtiene los datos de financiamiento
	set @SaldoPrestFin = 0
	set @SaldoPrestFinInt = 0
	set @SaldoPrestFinC = 0

	select @SaldoPrestFin = isnull(sum(MontoCapital) ,0), @SaldoPrestFinC = isnull(count(MontoCapital) ,0 )
	from tCsPrestFin P, tCsPrestFinDet D
	where P.CodPrestFin = D.CodPrestFin
	and P.Estado = '1'
	and P.Categoria = '2'
	and D.FechaVencimiento between @FechaCierre and @FechaVenc

	select @SaldoPrestFinInt = isnull(sum(MontoInteres) ,0)
	from tCsPrestFin P, tCsPrestFinDet D
	where P.CodPrestFin = D.CodPrestFin
	and P.Estado = '1'
	and P.Categoria = '2'
	and D.FechaVencimiento between @FechaCierre and @FechaVenc

	--select @SaldoDepoVista , @SaldoAho , @SaldoReti , @SaldoPrestFin , @SaldoAhoInt , @SaldoRetiInt , @SaldoPrestFinInt
	Set @Plazo1_7 = @SaldoDepoVista + @SaldoAho + @SaldoReti + @SaldoPrestFin + @SaldoAhoInt + @SaldoRetiInt + @SaldoPrestFinInt
	Set @Plazo1_7C = @SaldoDepoVistaC + @SaldoAhoC + @SaldoRetiC + @SaldoPrestFinC
	
	---------------------  PLAZOS ---------------------------
	
	--exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',0,7,@Plazo1_7 out ,@Plazo1_7C out
	exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',8,31,@Plazo8_1 out ,@Plazo8_1C out
	exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',32,90,@Plazo1_3 out ,@Plazo1_3C out 
	exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',91,180,@Plazo3_6 out ,@Plazo3_6C out 
	exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',181,365,@Plazo6_12 out ,@Plazo6_12C out 
	exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',366,730,@Plazo12_24 out ,@Plazo12_24C out 
	exec pCoObtieneSaldoCaptPlazosCs @Fecha,'D',731,6000,@Plazo24_99 out ,@Plazo24_99C out 
				
	----------------------------- RANGO UDIS ----------------------------
	exec pCoObtieneSaldoCaptPlazoRangosCs @Fecha,@TCUDIS,0,5000.9999,@Rango0_5 out ,@Rango0_5C out 
	exec pCoObtieneSaldoCaptPlazoRangosCs @Fecha,@TCUDIS,5001,10000.9999,@Rango5_10 out ,@Rango5_10C out 
	exec pCoObtieneSaldoCaptPlazoRangosCs @Fecha,@TCUDIS,10001,15000.9999,@Rango10_15 out ,@Rango10_15C out 
	exec pCoObtieneSaldoCaptPlazoRangosCs @Fecha,@TCUDIS,15001,20000.9999,@Rango15_20 out ,@Rango15_20C out 
	exec pCoObtieneSaldoCaptPlazoRangosCs @Fecha,@TCUDIS,20001,25000.9999,@Rango20_25 out ,@Rango20_25C out 
	exec pCoObtieneSaldoCaptPlazoRangosCs @Fecha,@TCUDIS,25001,9999999.9999,@Rango25_99 out ,@Rango25_99C out 
	---------------------------------------------------------

	Select @Plazo1_7 as Plazo1_7, @Plazo1_7C as Plazo1_7C, @Plazo8_1 as Plazo8_1, @Plazo8_1C as Plazo8_1C,
               @Plazo1_3 as Plazo1_3, @Plazo1_3C as Plazo1_3C, @Plazo3_6 as Plazo3_6, @Plazo3_6C as Plazo3_6C,
               @Plazo6_12 as Plazo6_12, @Plazo6_12C as Plazo6_12C, @Plazo12_24 as Plazo12_24, 
               @Plazo12_24C as Plazo12_24C, @Plazo24_99 as Plazo24_99, @Plazo24_99C as Plazo24_99C,
               @Rango0_5 as Rango0_5, @Rango0_5C as Rango0_5C, @Rango5_10 as Rango5_10, @Rango5_10C as Rango5_10C,
	       @Rango10_15 as Rango10_15, @Rango10_15C as Rango10_15C, @Rango15_20 as Rango15_20, 
               @Rango15_20C as Rango15_20C, @Rango20_25 as Rango20_25, @Rango20_25C as Rango20_25C,
               @Rango25_99 as Rango25_99, @Rango25_99C as Rango25_99C, @TCUDIS AS UDIS

GO