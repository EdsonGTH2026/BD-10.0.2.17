SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCoObtieneSaldosyNroCs](
		 @Fecha as smalldatetime,
		 @Tipo As integer,
		 @TipoInstFin As varchar(3),
		 @Saldo as money output,
		 @Nro as int output)

with encryption
AS
set nocount on 

DECLARE @FechaCierre as DateTime
DECLARE @FechaProceso as DateTime
DECLARE @FechaProm smalldatetime
DECLARE @Mes int
DECLARE @Anio int

DECLARE @Tabla table (Grupo char(1), Secuencial int, Localidad varchar(6), 
                      NroCuentas int, Monto money) 

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

	If @Tipo=1 
	begin
		-- Devuelve la suma de los saldos para dep. a la vista
		select @Saldo = isnull( sum(MontoGiro), 0 ), @Nro = isnull( count(MontoGiro), 0)
		from (Select CodOficinaOrigen, MontoGiro
			from tCsGiros
			where FechaPago is null
			and TipoGiro = 'R'
			and (EstadoGiro = 'P' or EstadoGiro = 'U')
			union all
			Select CodOficinaOrigen, MontoGiro
			from tCsGiros
			where FechaPago <= @FechaCierre
			and TipoGiro = 'R'
			and EstadoGiro = 'G') G
	end

	if @Tipo=2
	begin
		-- Devuelve la suma de los saldos para ahorros
		select @Saldo = isnull(sum(SaldoCuenta), 0), @Nro = isnull( count(SaldoCuenta), 0 )
		from tCsAhorros
		where CodProducto not like '2%'
		and IdEstadoCta <> 'CC'
		and Fecha = @FechaCierre
	end

	if @Tipo=3
	begin
		-- Devuelve la suma de los saldos
		select @Saldo = isnull( sum(SaldoCuenta), 0 ), @Nro = isnull(count(SaldoCuenta) ,0)
		from tCsAhorros
		where CodProducto like '2%'
		      and (FechaCierre <= @FechaCierre or FechaCierre is null)
		      and FechaVencimiento >= @FechaCierre
		      AND CodCuenta + FraccionCta + Cast(Renovado as VArChar(100)) IN 
								(SELECT CodCuenta + FraccionCta + Cast(Renovado As VarChar(100))
							   	 FROM tCsAhorros 
								 WHERE Fecha = @FechaCierre AND CodProducto like '2%'
								       AND IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV')
	end

	if @Tipo=4
	begin
		-- Devuelve la suma de los saldos
		select @Saldo = isnull(sum(MontoCapital), 0) , @Nro = isnull(count(MontoCapital) , 0)
		from (select F.CodOficina, F.CodPrestFin, sum(MontoCapital) as MontoCapital
			from tCsPrestFin F, tCsPrestFinDet D
			where F.CodPrestFin = D.CodPrestFin
			and CodTipoInstFin = @TipoInstFin
			and Estado = '1'
			and Categoria = '2'
			and D.FechaVencimiento >= @FechaCierre
			group by F.CodOficina, F.CodPrestFin) F	
	end
GO