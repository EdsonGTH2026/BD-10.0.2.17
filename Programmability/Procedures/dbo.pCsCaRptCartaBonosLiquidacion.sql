SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaRptCartaBonosLiquidacion] (@codpromotor varchar(20), @fecha smalldatetime)
as
begin
	set nocount on
	
	declare @FecIni smalldatetime
	declare @FecFin smalldatetime
	select @FecIni = dbo.fdufechaaperiodo(@fecha) + '01', @FecFin = FecFinSem4    
	from tCsCaRptCartaBonosFechas where periodo = dbo.fdufechaaperiodo(@fecha)

	declare @liquidaciones table(
	LiquidadosNro int,
	LiquidadosMonto money,
	PendientesNro int,
	PendientesMonto money,
	RenovadosNro int,
	RenovadosMonto money,
	RenovadosPorc money
	)
	
	declare @CanceladosNro int
	declare @CanceladosMonto money
	declare @PorRenovarNro int
	declare @PorRenovarMonto money
	declare @RenovadosNro int 
	declare @RenovadosMonto money
	declare @RenovadosPorc money

--	select * from @liquidaciones

	insert into @liquidaciones (LiquidadosNro, LiquidadosMonto, PendientesNro, PendientesMonto, RenovadosNro, RenovadosMonto, RenovadosPorc)
	values (0, 0, 0, 0, 0, 0,0)
	
	--Obtiene cancelados
	select @CanceladosNro = count(codprestamo), @CanceladosMonto = sum(monto)
	from tCsACaLIQUI_RR
	where codpromotor = @codpromotor
	and cancelacion >= @FecIni and cancelacion <= @FecFin
	
	--Obtiene pendientes x renovar
	select @PorRenovarNro = count(codprestamo), @PorRenovarMonto = sum(monto)
	from tCsACaLIQUI_RR
	where codpromotor = @codpromotor
	and cancelacion >= @FecIni and cancelacion <= @FecFin
	and Estado = 'Sin Renovar'
	
	--Obtiene Renovados
	select @RenovadosNro = count(codprestamo), @RenovadosMonto = sum(monto)
	from tCsACaLIQUI_RR
	where codpromotor = @codpromotor
	and cancelacion >= @FecIni and cancelacion <= @FecFin
	and Estado = 'Renovado'
	
	set @RenovadosPorc = 0
	if @CanceladosNro > 0
	begin
	set @RenovadosPorc = (100.0/@CanceladosNro)*@RenovadosNro
	end
	
	--Actualiza tabla temporal
	update @liquidaciones set
	LiquidadosNro = @CanceladosNro, 
	LiquidadosMonto = @CanceladosMonto,
	PendientesNro = @PorRenovarNro, 
	PendientesMonto = @PorRenovarMonto,
	RenovadosNro = @RenovadosNro, 
	RenovadosMonto = @RenovadosMonto,
	RenovadosPorc = @RenovadosPorc
	select LiquidadosNro, LiquidadosMonto, PendientesNro, PendientesMonto, RenovadosNro, RenovadosMonto, RenovadosPorc
	from   @liquidaciones 
end
GO