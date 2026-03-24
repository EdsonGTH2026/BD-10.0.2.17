SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCoObtieneSaldoDepoRetraOfiCs](
		 @Fecha as smalldatetime, 
		 @Saldo as money output,
		 @Nro as int output)

with encryption
AS
set nocount on 

declare @Grupo as char(1)	-- 4: Depósitos retirables en días preestablecidos
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
	
	set @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	
	SET @FechaProceso = DateAdd(Month,1,@FechaProm) --primer dia de mes despues del cierre
	SET @FechaCierre = DateAdd(Day, -1, @FechaProceso) --fecha de cierre, ultimo dia de mes

	set @Grupo = '4'

	-- Obtiene los depositos rtirables y los inserta en la tabla auxiliar para el reporte
	insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
	select @Grupo , O.Orden, CodUbiGeo,  isnull( sum(SaldoCuenta), 0 ), isnull(count(SaldoCuenta) ,0)
	from tCsClOficinas O
	left join (select CodOficina, SaldoCuenta
		   from tCsAhorros
		   where CodProducto like '2%'
		         and (FechaCierre <= @FechaCierre or FechaCierre is null)
		         and FechaVencimiento >= @FechaCierre
		         AND CodCuenta + FraccionCta + Cast(Renovado as VArChar(100)) IN 
							(SELECT CodCuenta + FraccionCta + Cast(Renovado As VarChar(100))
						   	 FROM tCsAhorros
							 WHERE Fecha = @FechaCierre AND CodProducto like '2%'
							       AND IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV')) D
	on O.CodOficina = D.CodOficina
	group by CodUbiGeo, O.Orden

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



GO