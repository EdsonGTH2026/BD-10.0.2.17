SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCoObtieneSaldoDepoFinInvCs](
		 @TipoInstFin as varchar(3),
		 @Categoria as char(1),
		 @Fecha as smalldatetime,
		 @SaldoMes as money out, 
                 @SaldoInt as money out, 
                 @SaldoPromMes as money out, 
                 @SaldoIntMes as money out, 
                 @Comision as money out
		 ) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @DiaMes int
declare @FechaProm smalldatetime
declare @Mes int
declare @Anio int
declare @ComisionAux as money


	-- Obtiene los saldos de financiamiento - inversión
	select @SaldoMes = isnull ( sum(MontoCapital), 0), @SaldoInt = isnull ( sum(MontoInteres), 0)
	from tCsPrestFin F, tCsPrestFinDet D
	where F.CodPrestFin = D.CodPrestFin
	and CodTipoInstFin = @TipoInstFin
	and Estado = '1'
	and Categoria = @Categoria
	and D.FechaVencimiento >= @Fecha

	-- Calcula el promedio mensual del saldo diario

	set @SaldoPromMes = 0
	set @SaldoIntMes = 0
	Set @DiaMes = 0
	set @FechaProm = dateadd(month, -1, @Fecha)

	-- Intereses del mes
	select @SaldoPromMes = isnull( sum(MontoInteres), 0)
	from tCsPrestFin F, tCsPrestFinDet D
	where F.CodPrestFin = D.CodPrestFin
	and CodTipoInstFin = @TipoInstFin
	and Estado = '1'
	and Categoria = @Categoria
	and D.FechaVencimiento between @FechaProm and @Fecha

	while (@FechaProm) <> (@Fecha)
	begin
		select @SaldoPromMes = @SaldoPromMes + isnull ( sum(MontoCapital), 0)
		from tCsPrestFin F, tCsPrestFinDet D
		where F.CodPrestFin = D.CodPrestFin
		and CodTipoInstFin = @TipoInstFin
		and Estado = '1'
		and Categoria = @Categoria
		and D.FechaVencimiento >= @FechaProm
				
		set @FechaProm = dateadd( day, 1, @FechaProm)
		set @DiaMes = @DiaMes + 1
	end


	if @Diames <> 0
		set @SaldoPromMes = @SaldoPromMes / @DiaMes	
		
	if @TipoInstFin <> '001' 
		set @Comision = 0
	else
	begin
		exec pCoObtieneSaldoCtaCs '550110301' , '-1', @Fecha,  @Comision out
	end		

	
GO