SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[pCaRptRegCaptacionesCs](
		 @Fecha as smalldatetime) 

with encryption
AS
set nocount on

declare @DiaMes int
DECLARE @FechaCierre as DateTime
DECLARE @FechaProceso as DateTime
declare @FechaProm smalldatetime
declare @Mes int
declare @Anio int

declare @1DepoVisA money
declare @1DepoVisB money
declare @1DepoVisD money
declare @1DepoVisE money
declare @1DepoVisF money
declare @1DepoAhoA money
declare @1DepoAhoB money
declare @1DepoAhoD money
declare @1DepoAhoE money
declare @1DepoAhoF money
declare @1DepoRetA money
declare @1DepoRetB money
declare @1DepoRetD money
declare @1DepoRetE money
declare @1DepoRetF money
declare @2PrestInstBanMulA money
declare @2PrestInstBanMulB money
declare @2PrestInstBanMulD money
declare @2PrestInstBanMulE money
declare @2PrestInstBanMulF money
declare @2PrestInstBanDesA money
declare @2PrestInstBanDesB money
declare @2PrestInstBanDesD money
declare @2PrestInstBanDesE money
declare @2PrestInstBanDesF money
declare @2PrestBanExtA money
declare @2PrestBanExtB money
declare @2PrestBanExtD money
declare @2PrestBanExtE money
declare @2PrestBanExtF money
declare @2PrestFideA money
declare @2PrestFideB money
declare @2PrestFideD money
declare @2PrestFideE money
declare @2PrestFideF money
declare @2PrestLiqA money
declare @2PrestLiqB money
declare @2PrestLiqD money
declare @2PrestLiqE money
declare @2PrestLiqF money
declare @2PrestOtrA money
declare @2PrestOtrB money
declare @2PrestOtrD money
declare @2PrestOtrE money
declare @2PrestOtrF money

	--------- DEPOSITOS A LA VISTA --------------------
	set @1DepoVisD = 0
	set @1DepoVisA = 0
	-- Obtiene los depositos a la vista
	select @1DepoVisA = isnull( sum(MontoGiro), 0 ), @1DepoVisD = isnull( sum(MontoGiro), 0 )
	from tCsGiros
	where FechaPago is null
	and TipoGiro = 'R'
	and (EstadoGiro = 'P' or EstadoGiro = 'U')

	select @1DepoVisA = @1DepoVisA + isnull( sum(MontoGiro), 0 )
	from tCsGiros
	where FechaPago <= @Fecha
	and TipoGiro = 'R'
	and EstadoGiro = 'G'

	-- No tiene intereses
	set @1DepoVisB = 0
	set @1DepoVisE = 0

	-- Calcula el promedio mensual del saldo diario
	Set @DiaMes = 0
	
	set @FechaProm = dateadd(month, -1, @Fecha)

	while (@FechaProm) <> (@Fecha)
	begin
		select @1DepoVisD = @1DepoVisD + isnull( sum(MontoGiro), 0 )
		from tCsGiros
		where FechaPago <= @FechaProm
		and TipoGiro = 'R'
		and EstadoGiro = 'G'

		set @FechaProm = dateadd( day, 1, @FechaProm)
		set @DiaMes = @DiaMes + 1
	end

	if @Diames <> 0
		set @1DepoVisD = @1DepoVisD / @DiaMes

	
	set @1DepoVisF = 0
	
	-------------- AHORROS -------------------
	
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
	SET @FechaCierre= @Fecha

	-- Obtiene los depositos de ahorro, con los ultimos saldos despues del cierre y los intereces acumulados q no pertenezcan a capitalizacion no mensual
	select @1DepoAhoA = isnull( sum(SaldoCuenta), 0 ), @1DepoAhoB = isnull( sum(IntAcumulado), 0 )
	from tCsAhorros
	where CodProducto not like '2%'
		and IdEstadoCta <> 'CC'
		and Fecha = @FechaCierre

	-- Calcula el promedio mensual del saldo diario

	set @1DepoAhoD = 0
	Set @DiaMes = 0
	
	while (@FechaProm) <> (@FechaProceso)
	begin
		select @1DepoAhoD = @1DepoAhoD + isnull( sum(SaldoCuenta), 0 )
		from tCsAhorros
		where CodProducto not like '2%'
		and IdEstadoCta <> 'CC'
		and Fecha = @FechaCierre

		set @FechaProm = dateadd( day, 1, @FechaProm)
		set @DiaMes = @DiaMes + 1
	end

	if @Diames <> 0
		set @1DepoAhoD = @1DepoAhoD / @DiaMes
	
	set @1DepoAhoE = 0
	
	--select * from tCsTransaccionDiaria

	SELECT @1DepoAhoE = IsNull(SUM(IsNull(MontoTotalTran,0)),0)
	FROM tCsTransaccionDiaria 
	WHERE cast(floor(cast(Fecha as float)) as datetime) = @FechaCierre
	      AND TipoTransacNivel3 = 15
	
	set @1DepoAhoF = 0
	
	--Se calcula las comisiones de acuerdo a la tabla de tipoTrans de AH
	SELECT @1DepoAhoF = SUM(CASE WHEN T.TipoTransacNivel1 = 'E' THEN ((-1)* T.MontoTotalTran) ELSE T.MontoTotalTran END)
	FROM tCsTransaccionDiaria T
	INNER JOIN tCsClTipoTransacNivel3 C ON C.TipoTransacNivel3=T.TipoTransacNivel3
	WHERE T.Fecha= @FechaCierre AND (C.EsComision = 1 OR T.TipoTransacNivel3 = 16 OR T.TipoTransacNivel3 = 17 )
	
	SET @1DepoAhoF = IsNull(@1DepoAhoF,0)

	----------------- RET -----------------
/*
	set @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	
	SET @FechaProceso = DateAdd(Month,1,@FechaProm) --primer dia de mes despues del cierre
	SET @FechaCierre = DateAdd(Day, -1, @FechaProceso) --fecha de cierre, ultimo dia de mes

*/
	-- Obtiene los depositos a la vista
/*
	select @1DepoRetA = isnull( sum(SaldoCuenta), 0 )
	from tCsAhorros
	where CodProducto like '2%'
	      and (FechaCierre <= @FechaCierre OR FechaCierre is null)
	      and FechaVencimiento >= @FechaCierre
	      AND CodCuenta + FraccionCta + Cast(Renovado As VarChar(100)) IN (SELECT CodCuenta + FraccionCta + Cast(Renovado As VarChar(100))
									       FROM tCsAhorros
									       WHERE CodProducto like '2%'
									       and Fecha = @FechaCierre
									       and IdEstadoCta <> 'CC'
									       AND IdEstadoCta <> 'CV')
*/

	select @1DepoRetA = isnull( sum(SaldoCuenta), 0 )
	from tCsAhorros
	where CodProducto like '2%'
	      and Fecha = @FechaCierre
		  and IdEstadoCta not in('CC', 'CV')

	-- Intereses
	select @1DepoRetB = isnull( sum(IntAcumulado), 0)
	from tCsAhorros
	where CodProducto like '2%'
		and Fecha = @FechaCierre
		and idEstadoCta <> 'CC'
		AND idEstadoCta <> 'CV'


	set @1DepoRetD = 0
	Set @DiaMes = 0
	
	while (@FechaProm) <> (@FechaProceso)
	begin
		
		SELECT @1DepoRetD = @1DepoRetD + IsNull(Sum(SaldoCuenta),0)
		FROM tCsAhorros
		WHERE CodProducto like '2%'
			and Fecha = @FechaProm
			and IdEstadoCta <> 'CC'
			AND IdEstadoCta <> 'CV'

		set @FechaProm = dateadd( day, 1, @FechaProm)
		set @DiaMes = @DiaMes + 1
	end

	if @Diames <> 0
		set @1DepoRetD = @1DepoRetD / @DiaMes
	

	SET @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	

	select @1DepoRetE = isnull( sum(Monto), 0)
	from tCsIntPeriodicos
	where IdEstadoCta = 'IR'
	and TipoPago = 'INT'
	and FechaPagado between @FechaProm and @Fecha

	set @1DepoRetF = 0

	--------------- PRESTAMOS FINANCIAMIENTO ----------------------

	exec pCoObtieneSaldoDepoFinInvCs '001','2',@Fecha,@2PrestInstBanMulA out ,@2PrestInstBanMulB out ,@2PrestInstBanMulD out ,@2PrestInstBanMulE out ,@2PrestInstBanMulF out 
	exec pCoObtieneSaldoDepoFinInvCs '002','2',@Fecha,@2PrestInstBanDesA out ,@2PrestInstBanDesB out ,@2PrestInstBanDesD out ,@2PrestInstBanDesE out ,@2PrestInstBanDesF out 
	exec pCoObtieneSaldoDepoFinInvCs '003','2',@Fecha,@2PrestBanExtA out ,@2PrestBanExtB out ,@2PrestBanExtD out ,@2PrestBanExtE out ,@2PrestBanExtF out 
	exec pCoObtieneSaldoDepoFinInvCs '004','2',@Fecha,@2PrestFideA out ,@2PrestFideB out ,@2PrestFideD out ,@2PrestFideE out ,@2PrestFideF out 
	exec pCoObtieneSaldoDepoFinInvCs '005','2',@Fecha,@2PrestLiqA out ,@2PrestLiqB out ,@2PrestLiqD out ,@2PrestLiqE out ,@2PrestLiqF out 
	exec pCoObtieneSaldoDepoFinInvCs '006','2',@Fecha,@2PrestOtrA out ,@2PrestOtrB out , @2PrestOtrD out ,@2PrestOtrE out ,@2PrestOtrF out 

	-----------------------------------------------

	select @1DepoVisA as DepoVistaA1, @1DepoVisB as DepoVisB1, @1DepoVisD as DepoVisD1, @1DepoVisE as DepoVisE1, 
               @1DepoVisF as DepoVisF1, @1DepoAhoA as DepoAhoA1, @1DepoAhoB as DepoAhoB1, @1DepoAhoD as DepoAhoD1, 
               @1DepoAhoE as DepoAhoE1, @1DepoAhoF as DepoAhoF1, @1DepoRetA as DepoRetA1, @1DepoRetB as DepoRetB1, 
               @1DepoRetD as DepoRetD1, @1DepoRetE as DepoRetE1, @1DepoRetF as DepoRetF1, isnull(@2PrestInstBanMulA,0) as PrestInstBanMulA2, 
               isnull(@2PrestInstBanMulB,0) as PrestInstBanMulB2, isnull(@2PrestInstBanMulD ,0)as PrestInstBanMulD2, isnull(@2PrestInstBanMulE,0) as PrestInstBanMulE2, 
               isnull(@2PrestInstBanMulF,0) as PrestInstBanMulF2, isnull(@2PrestInstBanDesA,0) as PrestInstBanDesA2, isnull(@2PrestInstBanDesB,0) as PrestInstBanDesB2, 
               isnull(@2PrestInstBanDesD,0) as PrestInstBanDesD2, isnull(@2PrestInstBanDesE,0) as PrestInstBanDesE2, isnull(@2PrestInstBanDesF,0) as PrestInstBanDesF2,
	       isnull(@2PrestBanExtA,0) as PrestBanExtA2, isnull(@2PrestBanExtB,0) as PrestBanExtB2, isnull(@2PrestBanExtD,0) as PrestBanExtD2, 
               isnull(@2PrestBanExtE,0) as PrestBanExtE2, isnull(@2PrestBanExtF,0) as PrestBanExtF2, isnull(@2PrestFideA,0) as PrestFideA2, 
               isnull(@2PrestFideB,0) as PrestFideB2, isnull(@2PrestFideD,0) as PrestFideD2, isnull(@2PrestFideE,0) as PrestFideE2, isnull(@2PrestFideF,0) as PrestFideF2,
               isnull(@2PrestLiqA,0) as PrestLiqA2, isnull(@2PrestLiqB,0) as PrestLiqB2, isnull(@2PrestLiqD,0) as PrestLiqD2, isnull(@2PrestLiqE,0) as PrestLiqE2, 
               isnull(@2PrestLiqF,0) as PrestLiqF2, isnull(@2PrestOtrA,0) as PrestOtrA2, isnull(@2PrestOtrB,0) as PrestOtrB2, isnull(@2PrestOtrD ,0)as PrestOtrD2, 
               isnull(@2PrestOtrE,0) as PrestOtrE2, isnull(@2PrestOtrF,0) as PrestOtrF

GO