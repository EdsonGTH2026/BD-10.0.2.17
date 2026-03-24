SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pXaValidarAppPoliticas](@CodProducto varchar(3),@Ciclo int,@MontoSolicitado money, @Periodicidad varchar(1), @Plazo int, @Tasa money, @MontoAnterior money )
as
begin
	/*
	declare @CodProducto varchar(3)
	declare @Ciclo int 
	declare @MontoSolicitado money
	declare @Periodicidad varchar(1)
	declare @Plazo int
	declare @Tasa money
	declare @MontoAnterior money 
	declare @MontoSolicitado money
	set @CodProducto = '170'
	set @Ciclo = 2
	set @MontoSolicitado = 5500
	set Periodicidad = 'S'
	set @Plazo = 24
	set @Tasa = 100
	set @MontoAnterior money 
	set @MontoSolicitado money
	*/
	declare @Mensaje varchar(150)
	declare @MontoMin money
	declare @MontoMax money
	declare @PeriodicidadPermitida varchar(10)
	declare @PlazoPermitido varchar(30)
	declare @PlazoPeriodo varchar(4)
	declare @TasaPermitida money
	declare @IncremetoPorc money
	declare @DecremetoPorc money
	declare @IncremetoMonto money
	declare @IncremetoMontoDif money
	declare @DecremetoMonto money
	declare @DecremetoMontoDif money

	set @Mensaje = 'OK'
	
	select @MontoMin= MontoMin, @MontoMax = MontoMax, 
	@PeriodicidadPermitida = Periodicidad, 
	@PlazoPermitido = Plazo,
	@TasaPermitida = Tasa,
	@IncremetoPorc = PorcenIncreReno,
	@DecremetoPorc = PorcenDecreReno
	from tCsCaAppPoliticas 
	where CodProducto = @CodProducto and CicloMin <= @Ciclo and CicloMax >= @Ciclo

	--Monto
	if (@MontoSolicitado < @MontoMin or @MontoSolicitado > @MontoMax)
	begin
		set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], el monto debe estar entre [$' + convert(varchar,@MontoMin)+' - $' + convert(varchar,@MontoMax)+']'
		select @Mensaje as Mensaje
		return 0
	end
	
	--Periodicidad
	if charindex(@Periodicidad,@PeriodicidadPermitida) = 0
	begin
		set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], no se permite la Periodicidad seleccionada'
		select @Mensaje as Mensaje
		return 0
	end
	
	--PLAZO
	--@PlazoPermitido
	set @PlazoPeriodo = convert(varchar,@Plazo) +'/'+ @Periodicidad
	--select @PlazoPeriodo
	
	if charindex(@PlazoPeriodo,@PlazoPermitido) = 0
	begin
		set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'],no esta permitido el Plazo/Periodo['+ @PlazoPeriodo + '], Solo solo se permiten el Plazo/Periodo[' + @PlazoPermitido + ']'
		select @Mensaje as Mensaje
		return 0
	end
	
	--Tasa
	--if (@Tasa <> @TasaPermitida)
	--begin
	--	set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], la Tasa permitida es de [' + convert(varchar,@TasaPermitida)+'%]'
	--	select @Mensaje as Mensaje
	--	return 0
	--end
	
	--Incremento
	if @MontoAnterior > 0 and (@MontoAnterior < @MontoSolicitado)
	begin
		set @IncremetoMonto = @MontoSolicitado * (@IncremetoPorc/100)
		set @IncremetoMontoDif = @MontoSolicitado - @MontoAnterior
		
		if @IncremetoMontoDif > @IncremetoMonto
		begin
			set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], el Incremento Permitido es de ['+ convert(varchar,@IncremetoPorc) +'%] = [$'+convert(varchar,@IncremetoMonto)+']'
			select @Mensaje as Mensaje
			return 0
		end
	end
	
	--Decremento
	if @MontoAnterior > 0 and (@MontoAnterior > @MontoSolicitado)
	begin
		set @DecremetoMonto = @MontoSolicitado * (@DecremetoPorc/100)
		set @DecremetoMontoDif = @MontoAnterior - @MontoSolicitado  
		
		if @DecremetoMontoDif > @DecremetoMonto
		begin
			set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], el Decremento Permitido es de ['+ convert(varchar,@DecremetoPorc) +'%] = [$'+convert(varchar,@DecremetoMonto)+']'
			select @Mensaje as Mensaje
			return 0
		end
	end
	
	
	
	select @Mensaje as Mensaje 

end
GO