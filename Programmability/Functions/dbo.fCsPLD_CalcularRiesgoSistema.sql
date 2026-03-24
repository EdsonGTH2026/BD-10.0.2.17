SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fCsPLD_CalcularRiesgoSistema](@CodUsuario varchar(20), @MontoPeriodo money )
RETURNS varchar(20)      
AS
BEGIN

	/*
	declare @CodUsuario varchar(20)
	declare @MontoPeriodo money
	set @CodUsuario = 'BMA1001381'
	set @MontoPeriodo = 1508875.08
	*/


	declare @FechaHoy smalldatetime
	declare @CodOrigen varchar(20)
	declare @intTotalPuntos integer
	declare @intPuntos integer
	declare @CodTPersona varchar(2)
	declare @Riesgo varchar(10)
	declare @RiesgoCalculado varchar(10)
	
	set @intTotalPuntos = 0
	Select @FechaHoy = FechaConsolidacion From vCsFechaConsolidacion
	
	
	--############### TIPO DE PERSONA  ################
	--Personas Fisicas = 10
	--Personas Morales = 20
	
	set @intPuntos = 10 --Default
	select @CodTPersona = CodTPersona, @CodOrigen = CodOrigen from tCsPadronClientes with(nolock)
	where codusuario = @CodUsuario
	
	select 
	@intPuntos = (case when @CodTPersona = '01' then 10 
	              else 20
	              end) 

--select @intPuntos as 'tipo persona'
	
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+TIPO PERSONA => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--############### MONTO DE LA OPERACION ################
	-- de 1 a 499,999 mxn          = 10
	-- de 500,000 a 999,999 mxn    = 20
	-- mas de 1,000,000 mxn        = 30
	
if @CodTPersona = '01'  --FISICA
	begin
		select 
		@intPuntos = (case 
		              when @MontoPeriodo <= 499999 then 10 
		              when @MontoPeriodo >= 500000 and @MontoPeriodo <= 999999 then 20 
		              when @MontoPeriodo >= 1000000 then 30 
		              else 10
		              end) 
	end
else  --MORALES
	begin
		select 
		@intPuntos = (case 
		              when @MontoPeriodo <= 4999999 then 10 
		              when @MontoPeriodo >= 5000000 and @MontoPeriodo <= 9999999 then 20 
		              when @MontoPeriodo >= 10000000 then 30 
		              else 10
		              end) 
	end

--select @intPuntos as 'monto'
	
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+MONTO OPERACION => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--############### ACTIVIDAD ECONOMICA ################
	--Actividad Riesgo BAJO     = 10
	--Actividad Riesgo ALTO     = 20
	
	set @Riesgo = 'BAJO' --default
	
	select top 1
	-- CodActividad, Descripcion,  
	@Riesgo = Riesgo
	FROM [10.0.2.14].finmas.dbo.tClActividad as a
	inner join [10.0.2.14].finmas.dbo.tUsUsuarioSecundarios as us on us.LabCodActividad = a.CodActividad
	WHERE 1=1
	and a.Activo = 1 
	and (us.codusuario = @CodUsuario or us.codusuario = @CodOrigen) --in (select top 1 CodOrigen from tCsPadronClientes where CodUsuario = @CodUsuario)--@CodUsuario --'98pot2210781' 
	
	--print '@Riesgo: ' + @Riesgo	
	select 
	@intPuntos = (case 
	              when @Riesgo = 'BAJO' then 10 
	              when @Riesgo = 'ALTO'  then 20 
	              else 10
	              end) 

--select @intPuntos as 'actividad'
	
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+ACTIVIDAD ECONOMICA => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--############### EDAD ################
	--de 1 a 29       = 10
	--de 30 a 59      = 5
	--de 60 o mas     = 20
	
	declare @intAñosEdad integer
	select @intAñosEdad = (cast(datediff(dd,fechanacimiento,@FechaHoy) / 365.25 as int)) 
	from tCsPadronClientes with(nolock) where codusuario = @CodUsuario -- or codorigen = @CodUsuario
	
	--print '@intAñosEdad: ' + convert(varchar,@intAñosEdad)
--select @intPuntos as 'edad'

	select 
	@intPuntos = (case 
	              when @intAñosEdad <= 29 then 10 
	              when @intAñosEdad >= 30 and @intAñosEdad <= 59 then 5 
	              when @intAñosEdad >= 60 then 20 
	              else 10
	              end) 
	
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+EDAD => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	
	--############### RELACION COMERCIAL ################
	--menos 1 año        = 20
	--entre 1 y 4 años   = 10
	--mas de 4 años      = 5
	
	--select top 1 @FecPrimerCtaAhorro = fecapertura from tCsPadronAhorros where codusuario = 'BBM0105711' order by fecapertura
	--select top 1 @FecPrimerCredito = desembolso from tCsPadronCarteraDet where codusuario = 'MFJ0402631' order by desembolso
	
	declare @FecPrimer smalldatetime
	declare @intAñosAntiguedad integer
	
	select top 1 @FecPrimer = isnull(Fecha,'') 
	from (
		select fecapertura as Fecha from tCsPadronAhorros with(nolock) where codusuario = @CodUsuario
		union
		select desembolso as Fecha from tCsPadronCarteraDet with(nolock) where codusuario = @CodUsuario
	) as x
	order by x.Fecha
	
	select @intAñosAntiguedad = (cast(datediff(dd, @FecPrimer,@FechaHoy) / 365.25 as int)) 
	
	--print '@FecPrimer: ' + convert(varchar,@FecPrimer)
	--print '@intAñosAntiguedad: ' + convert(varchar,@intAñosAntiguedad)

	select 
	@intPuntos = (case 
	              when @intAñosAntiguedad < 1 then 20 
	              when @intAñosAntiguedad >= 1 and @intAñosAntiguedad <= 4 then 10 
	              when @intAñosAntiguedad > 4 then 5 
	              else 20
	              end) 

--select @intPuntos as 'relacion'
	
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+RELACION COMERCIAL => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--############### PRODUCTOS ################
	--producto 170           = 10
	--producto 170 c/aval    = 5
	--producto 370           = 10
	--producto 370 c/aval    = 5
	--Ahorro a la vista      = 30
	--Ahorro DPF             = 20
	
	--select * from tCsPadronAhorros where codusuario = 'BBM0105711' order by fecapertura
	--select * from tCsPadronCarteraDet where codusuario =  'MFJ0402631' order by desembolso
	--select top 10 * from tCsGarantias
	--select top 10 * from tCsPadronCarteraDet
	
	--PUNTOS PRODUCTOS CREDITO
	set @intPuntos = 0
	select 
	@intPuntos = isnull(sum(x.puntos),0)
	--isnull(sum(x.puntos),0)
	from (
		select 
		--c.CodPrestamo, c.CodUsuario, c.CodOficina, c.CodProducto,  
		distinct c.CodProducto, 
		isnull(g.DocPropiedad,'') as aval,
		(case 
		    when c.CodProducto = '170' and isnull(g.DocPropiedad,'') = '' then 10 
		    when c.CodProducto = '170' and isnull(g.DocPropiedad,'') <> '' then 5
		    when c.CodProducto = '370' and isnull(g.DocPropiedad,'') = '' then 10
		    when c.CodProducto = '370' and isnull(g.DocPropiedad,'') <> '' then 5
		    else 0
		 end) as Puntos
		from tCsPadronCarteraDet as c with(nolock)
		left join tCsGarantias as g with(nolock) on g.codigo = c.codprestamo and TipoGarantia = 'IPN'
		where c.EstadoOriginal = 'ACTIVA' and c.codusuario = @CodUsuario --'MFJ0402631' --errro????????
	) as x
	
--select @intPuntos as 'producto credito'
	--print '@intPuntos Prod credito:' + convert(varchar,@intPuntos)
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+PRODUCTO CREDITO => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--PUNTOS PRODUCTOS AHORRO
	set @intPuntos = 0
	select @intPuntos = isnull(sum(x.puntos),0)
	from (
		select 
		--a.CodCuenta, a.CodUsuario, a.CodOficina, 
	    distinct left(a.CodProducto,1) as prod,   
		(case 
			when a.CodProducto = '111' then 0 
		    when a.CodProducto like '1%'  then 30 
		    when a.CodProducto like '2%'  then 20
		    else 0
		 end) as Puntos
		from tCsPadronAhorros as a with(nolock)
		where a.EstadoCalculado <> 'CC' and a.codusuario = @CodUsuario
	) as x
	
--select @intPuntos as 'producto ahorro'

	--print '@intPuntos Prod Ahorro:' + convert(varchar,@intPuntos)
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+PRODUCTO AHORRO => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--############### PEPS ################
	--No identificado           = 5
	--Identificado              = 20
	set @intPuntos = 0
	
	select 
	@intPuntos = (case 
	              when isnull(count(y.PPE_EsPersonaExpuesta),0) <> 0 then 5
	              else 20
	              end)
	from (
		--select top 10 * from [10.0.2.14].finmas.dbo.tUsAhorroDPF where PPE_EsPersonaExpuesta = 1 and (CodUsuario = @CodUsuario or codusuario = @CodOrigen)
		select PPE_EsPersonaExpuesta from [10.0.2.14].finmas.dbo.tUsAhorroDPF where (CodUsuario = @CodUsuario or codusuario = @CodOrigen)
	union
		--select PPE_EsPersonaExpuesta from [10.0.2.14].finmas.dbo.tUsCreditoSolicitud where PPE_EsPersonaExpuesta = 1 and (CodUsuario = @CodUsuario or codusuario = @CodOrigen)
		select PPE_EsPersonaExpuesta from [10.0.2.14].finmas.dbo.tUsCreditoSolicitud where (CodUsuario = @CodUsuario or codusuario = @CodOrigen)
	) as y
	
--select @intPuntos as 'peps'
	
	--print '@intPuntos PEPS:' + convert(varchar,@intPuntos)
	set @intTotalPuntos = @intTotalPuntos + @intPuntos
	--print '+PEPS => @intPuntos = ' + convert(varchar,@intPuntos) + ', @intTotalPuntos = ' + convert(varchar,@intTotalPuntos)  
	
	--################## DETERMINA EL NIVEL DE RIESGO ########################
	--De 0 a 80 puntos          => RIESGO BAJO
	--De 81 a 120 puntos          => RIESGO MEDIO
	--De 120 en adelante          => RIESGO ALTO
	
	select 
	@RiesgoCalculado = (case 
	              when @intTotalPuntos <= 80 then 'BAJO' 
	              when @intTotalPuntos >= 81 and @intTotalPuntos <= 120 then 'MEDIO' 
	              when @intTotalPuntos > 120 then 'ALTO'
	              else 'BAJO'
	              end) 
	--Print '=Riesgo calculado = ' + @RiesgoCalculado
	--select @RiesgoCalculado as Riesgo

--select @intTotalPuntos as '@intTotalPuntos'

    RETURN @RiesgoCalculado
END 
GO

GRANT EXECUTE ON [dbo].[fCsPLD_CalcularRiesgoSistema] TO [rie_jaguilar]
GO

GRANT EXECUTE ON [dbo].[fCsPLD_CalcularRiesgoSistema] TO [ayescasc]
GO