SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCoObtieneSaldoCaptPlazosCs](
		 @Fecha as smalldatetime,
		 @TipoPlazo as char(1),    	-- Tipo de Plazo D:Dia, M: Mes, A: Año
		 @PlazoInf as int,		-- Limite inferior del plazo en las unidades establecidas
		 @PlazoSup as int,		-- Limite superior del plazo en las unidades establecidas
                 @Saldo as money out,
		 @Nro as int out
) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @SaldoReti as money
declare @SaldoRetiInt as money
declare @SaldoRetiC as int

declare @SaldoPrestFin as money
declare @SaldoPrestFinC as int 
declare @SaldoPrestFinInt as money

DECLARE @DiasPlazoInf as Int
DECLARE @DiasPlazoSup as Int

declare @FechaInf as smalldatetime
declare @FechaSup as smalldatetime
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

	if upper(@TipoPlazo) = 'D'
	begin
		set @FechaInf = dateadd(day, @PlazoInf, @Fecha)
		set @FechaSup = dateadd(day, @PlazoSup, @Fecha) - 1
		SET @DiasPlazoInf = @PlazoInf
		SET @DiasPlazoSup = @PlazoSup
		--select @FechaInf as fechainf,@FechaSup as fechasup,@DiasPlazoInf as inf,@DiasPlazoSup as sup
	end
	if upper(@TipoPlazo) = 'M'
	begin
		set @FechaInf = dateadd(month, @PlazoInf, @FechaCierre)
		set @FechaSup = dateadd(month, @PlazoSup, @FechaCierre) - 1
		SET @DiasPlazoInf = @PlazoInf * 30
		SET @DiasPlazoSup = @PlazoSup * 30
	end
	if upper(@TipoPlazo) = 'A'
	begin
		set @FechaInf = dateadd(year, @PlazoInf, @FechaCierre)
		set @FechaSup = dateadd(year, @PlazoSup, @FechaCierre) - 1
		SET @DiasPlazoInf = @PlazoInf * 360
		SET @DiasPlazoSup = @PlazoSup * 360
	end

	set @SaldoReti = 0
	set @SaldoRetiC = 0
	
	
	SELECT @SaldoReti = isnull( sum(SaldoCuenta), 0 ), @SaldoRetiC = isnull( count(SaldoCuenta), 0)
	FROM tCsAhorros
	WHERE CodProducto like '2%'
	and (FechaCierre <= @FechaCierre or FechaCierre is null)
	AND Plazo >=  @DiasPlazoInf AND Plazo <= @DiasPlazoSup
	AND FechaApertura <=@FechaCierre
	AND CodCuenta IN (SELECT CodCuenta FROM tCsAhorros 
			  WHERE Fecha = @FechaCierre AND CodProducto like '2%' AND 
                                IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV')	
	
	-- Intereses
	SET @SaldoRetiInt = 0

	-- Obtiene los datos de financiamiento
	set @SaldoPrestFin = 0
	set @SaldoPrestFinInt = 0
	set @SaldoPrestFinC = 0

	select @SaldoPrestFin = isnull(sum(MontoCapital) ,0), @SaldoPrestFinC = isnull(count(MontoCapital) ,0 )
	from tCsPrestFin P, tCsPrestFinDet D
	where P.CodPrestFin = D.CodPrestFin
	and P.Estado = '1'
	and P.Categoria = '2'
	and D.FechaVencimiento between @Fechainf and @FechaSup

	select @SaldoPrestFinInt = isnull(sum(MontoInteres) ,0)
	from tCsPrestFin P, tCsPrestFinDet D
	where P.CodPrestFin = D.CodPrestFin
	and P.Estado = '1'
	and P.Categoria = '2'
	and D.FechaVencimiento between @FechaInf and @FechaSup

	
	Set @Saldo = isnull(@SaldoReti,0) + isnull(@SaldoPrestFin,0) + isnull(@SaldoRetiInt,0) + isnull(@SaldoPrestFinInt,0)
	Set @Nro = isnull(@SaldoRetiC,0) + isnull(@SaldoPrestFinC,0)

GO