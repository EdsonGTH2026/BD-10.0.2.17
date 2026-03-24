SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaValidarConceptoAppPoliticas](@CodProducto varchar(3),@Ciclo int, 
@IdentiOficial int,
@CURP int,
@CompDomicilio int,
@CompIngresos int,
@AutorizacionSIC int,
@FotoCliente int
)
as
begin
/*
	declare @CodProducto varchar(3)
	declare @Ciclo int
	declare @IdentiOficial int
	declare @CURP int
	declare @CompDomicilio int
	declare @CompIngresos int
	declare @AutorizacionSIC int
	declare @FotoCliente int
	set @CodProducto = '170'
	set @Ciclo = 1
	set @IdentiOficial = 0 
	--set @CURP = 0  
	--set @CompDomicilio = '0' 
	--set @CompIngresos = '0' 
	--set @AutorizacionSIC = '0' 
	--set @FotoCliente = '0'
*/

	declare @Mensaje varchar(150)
	declare @IdentiOficialConfig int
	declare @CURPConfig int
	declare @CompDomicilioConfig int
	declare @CompIngresosConfig int
	declare @AutorizacionSICConfig int
	declare @FotoClienteConfig int
	set @Mensaje = 'OK'

	--select @IdentiOficial, @CURP
	select 
	@IdentiOficialConfig = IdentiOficial, @CURPConfig=CURP, 
	@CompDomicilioConfig=CompDomicilio, @CompIngresosConfig=CompIngresos, 
	@AutorizacionSICConfig = AutorizacionSIC, @FotoClienteConfig = FotoCliente
	from tCsCaAppPoliticas 
	where CodProducto = @CodProducto 
	and CicloMin <= @Ciclo and CicloMax >= @Ciclo

	--IDENTIFICACION OFICIAL
	if isnull(@IdentiOficial,-1) <> -1 --i no viene nulo, entonce valida concepto
	begin 
		if @IdentiOficialConfig = 1
		begin
			if @IdentiOficial <> 1 
			begin
				set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], es necesario digitalizar Identificacion Oficial'
				select @Mensaje as Mensaje
				return 0
			end
		end
	end
	--CURP
	if isnull(@CURP,-1) <> -1 --i no viene nulo, entonce valida concepto
	begin 
		if @CURPConfig = 1
		begin
			if @CURP <> 1 
			begin
				set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], es necesario digitalizar la CURP del Cliente'
				select @Mensaje as Mensaje
				return 0
			end
		end
	end
	--COMP DOMICILIO
	if isnull(@CompDomicilio,-1) <> -1 --i no viene nulo, entonce valida concepto
	begin 
		if @CompDomicilioConfig = 1
		begin
			if @CompDomicilio <> 1 
			begin
				set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], es necesario digitalizar el Comprobante de Domicilio'
				select @Mensaje as Mensaje
				return 0
			end
		end
	end
	--COMP INGRESOS
	if isnull(@CompIngresos,-1) <> -1 --i no viene nulo, entonce valida concepto
	begin 
		if @CompIngresosConfig = 1
		begin
			if @CompIngresos <> 1 
			begin
				set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], es necesario digitalizar Comprobante de Ingresos'
				select @Mensaje as Mensaje
				return 0
			end
		end
	end
	--Autorizacion SIC
	if isnull(@AutorizacionSIC,-1) <> -1 --i no viene nulo, entonce valida concepto
	begin 
		if @AutorizacionSICConfig = 1
		begin
			if @AutorizacionSIC <> 1 
			begin
				set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], es necesario digitalizar Autorizacion SIC'
				select @Mensaje as Mensaje
				return 0
			end
		end
	end
	--FOTO CLIENTE
	if isnull(@FotoCliente,-1) <> -1 --i no viene nulo, entonce valida concepto
	begin 
		if @FotoClienteConfig = 1
		begin
			if @FotoCliente <> 1 
			begin
				set @Mensaje = 'Para el Ciclo['+convert(varchar,@Ciclo)+'], es necesario digitalizar Fotos Clientes'
				select @Mensaje as Mensaje
				return 0
			end
		end
	end


	select @Mensaje as Mensaje 


end

GO