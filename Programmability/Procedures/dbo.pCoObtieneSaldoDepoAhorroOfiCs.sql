SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCoObtieneSaldoDepoAhorroOfiCs](
		 @Fecha as smalldatetime,
		 @Saldo as money output,
		 @Nro as int output)

with encryption
AS
set nocount on 

declare @Grupo as char(1)	-- 2: Depósitos de Ahorro
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

	set @Grupo = '2'

	-- Obtiene los depositos de ahorro y los inserta en la tabla auxiliar para el reporte
	insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
	select @Grupo, O.orden, CodUbiGeo, isnull( sum(SaldoCuenta), 0 ), isnull( count(SaldoCuenta), 0 )
	from  tCsClOficinas O
	left join (select CodOficina, SaldoCuenta from tCsAhorros
			where CodProducto not like '2%'
			and IdEstadoCta <> 'CC'
			and Fecha = @FechaCierre) A
	on O.CodOficina = A.CodOficina
	group by CodUbiGeo, O.Orden
	
	-- Devuelve la suma de los saldos
	select @Saldo = isnull(sum(SaldoCuenta), 0), @Nro = isnull( count(SaldoCuenta), 0 )
	from tCsAhorros
	where CodProducto not like '2%'
	and IdEstadoCta <> 'CC'
	and Fecha = @FechaCierre

GO