SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCoObtieneSaldoDepoVistaCs](
	@Fecha as smalldatetime) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @SaldoMes money
declare @SaldoInt money
declare @SaldoPromMes money
declare @SaldoIntMes money
declare @DiaMes int
declare @FechaProm smalldatetime
declare @Mes int
declare @Anio int
declare @Comision as money

	set @SaldoPromMes = 0
	set @SaldoMes = 0
	-- Obtiene los depositos a la vista
	select @SaldoMes = isnull( sum(MontoGiro), 0 ), @SaldoPromMes = isnull( sum(MontoGiro), 0 )
	from tCsGiros
	where FechaPago is null
	and TipoGiro = 'R'
	and (EstadoGiro = 'P' or EstadoGiro = 'U')

	select @SaldoMes = @SaldoMes + isnull( sum(MontoGiro), 0 )
	from tCsGiros
	where FechaPago <= @Fecha
	and TipoGiro = 'R'
	and EstadoGiro = 'G'

	-- No tiene intereses
	set @SaldoInt = 0
	set @SaldoIntMes = 0

	-- Calcula el promedio mensual del saldo diario
	Set @DiaMes = 0
	--set @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)
	set @FechaProm = dateadd(month, -1, @Fecha)

	while (@FechaProm) <> (@Fecha)
	begin
		select @SaldoPromMes = @SaldoPromMes + isnull( sum(MontoGiro), 0 )
		from tCsGiros
		where FechaPago <= @FechaProm
		and TipoGiro = 'R'
		and EstadoGiro = 'G'

		set @FechaProm = dateadd( day, 1, @FechaProm)
		set @DiaMes = @DiaMes + 1
	end

	if @Diames <> 0
		set @SaldoPromMes = @SaldoPromMes / @DiaMes

	
	set @Comision = 0

	select @SaldoMes as SaldoMes, @SaldoInt as SaldoInt, @SaldoPromMes as SaldoPromMes, @SaldoIntMes as SaldoIntMes, @Comision as Comision

GO