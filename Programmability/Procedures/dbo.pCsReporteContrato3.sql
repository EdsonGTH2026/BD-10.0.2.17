SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Drop Procedure pCsReporteContrato3
--Exec pCsReporteContrato3 11, 'kvalera', 'ZZZ', '004-105-06-2-0-01207'
CREATE Procedure [dbo].[pCsReporteContrato3]
	@Dato			Int,
	@Usuario		Varchar(50) ,
	@Ubicacion		Varchar(500),
	@CodCuenta    	Varchar(25) = ''
As
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--@Dato:
--1: Es para Adendun. 
--2: Para Listar los firmantes del Adendum del Contrato.
--3: Es para ConsuLine.
--4: Prueba

--@FRA
--1: Para Firmar el Gerente de Agencia.
--2: Para Firmar el Coordinador de Operaciones.
--3: Para Firmar el Asesor de Ahorros.
--4:Prueba
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
Print 'Hora			: ' + Cast(datepart(Hour,			getdate())	as Varchar(10))
Print 'Minuto			: ' + Cast(datepart(Minute,			getdate())	as Varchar(10))
Print 'Segundo			: ' + Cast(datepart(Second,			getdate())	as Varchar(10))
Print 'Microsegundo	: ' + Cast(datepart(Millisecond,	getdate())	as Varchar(10))
Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
--Variable y Tablas Temporales y Generales
Declare @intTemporal	Int
Declare @intTemporal1	Int
Declare @vcrTemporal	Varchar(8000)
Declare @SiPl			Varchar(1)
Declare @Firma			Varchar(200)
Declare @CodOficina		Varchar(4)
Declare @FechaActual	DateTime
Declare @FRA			Int	
Declare @CodUsuario		Varchar(25)		

--Variables a Analizar para Automatización FINAL
Declare @Contador		Int
Declare @Cadena			Varchar(8000)
Declare @TempVC			Varchar(8000)
Declare @TempVC1		Varchar(8000)
Declare @TempVC2		Varchar(8000)
Declare @TempVC3		Varchar(8000)
Declare @TempVC4		Varchar(8000)
Declare @TempVC5		Varchar(8000)
Declare @TempVC6		Varchar(8000)
Declare @TempVC7		Varchar(8000)
Declare @TempVC8		Varchar(8000)
Declare @TempDC			Decimal(20,8)
Declare @TempDC1		Decimal(20,8)
Declare @TempIT			Int
Declare @TempIT1		Int
Declare @TempIT2		Int
Declare @TempIT3		Int
Declare @TempIT4		Int
Declare @Mayuscula		Bit
Declare @TipoClausula	Varchar(50)
Declare @OtroDato		Varchar(100)

Create Table #Etiqueta	--Para manejo de etiquetas.
(
	[Fila] 			[int] NOT NULL,
	[Etiqueta] 		[varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL,
	[Texto] 		[varchar] (8000) COLLATE Modern_Spanish_CI_AI NULL
)
 
Create Table #Sujeto	--Para manejo de nombre de clientes y de la Etiqueta [Sujeto]
(
	CodUsuario	Varchar(25),
	Sujeto		VArchar(100)
)

Create Table #Valor		--Para manejo de Valores de Etiquetas compuestas.
(
	[Valor] 		[varchar] (8000) COLLATE Modern_Spanish_CI_AI NULL
) 

Create Table #Oficina 
(
	[CodOficina] 	[varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL,
	[Orden] 		[int] NULL,
	[Direccion] 	[varchar] (500) COLLATE Modern_Spanish_CI_AI NULL,
	[DescOficina] 	[varchar] (100) COLLATE Modern_Spanish_CI_AI NULL
) 
	
--Variables para las Etiquetas
Declare @FechaApertura	Varchar(10)		--[FechaApertura]	: 18/05/2008
Declare @Sujeto			Varchar(500)	--[Sujeto]			: GARCIA ARRIAGA MARIA DE LOS ANGELES, AYALA VALERIO MARTHA
Declare @DenoSujeto		Varchar(50)		--[DenoSujeto]		: El CLIENTE, LOS CLIENTES
Declare @CreditosV		Varchar(1000)	--[CreditosV]		: [Nro: 006-116-06-00-01295 de fecha 18/05/2007] Y [Nro: 006-121-06-02-00536 de fecha 02/06/2007]
Declare @ODireccion		Varchar(500)	--[ODireccion]		: Calle Nicolas Bravo S/N., Ixtlahuaca de Rayón, Municipio de Ixtlahuaca, Estado de México, C.P. 50740
Declare @CDireccion		Varchar(500)	--[CDireccion]		: Calle  Principal  N°  65 Col. Providencia, Mun. Alto  Lucero  De  Gutiérrez  Barrios, Edo. Veracruz  De  Ignacio  De  La  Llave C.P. 91466
Declare @FechaFirma		Varchar(100)	--[FechaFirma]		: a los 28 días del mes de Febrero de 2010.
Declare @DI				Varchar(100)	--[DI]				: CE : APLPTD69081115M400
Declare @PaginaWeb		Varchar(100)	--[PaginaWeb]		: www.finamigo.com.mx
Declare @Ahorro			Varchar(25)		--[Ahorro]			: 006-102-06-2-6-00702

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--Iniciación de Variables Generales.
If @Dato > 10
Begin
	Set @FRA	= @Dato%10
	Set @Dato	= @Dato/10 
End
Else
Begin
	Set @FRA	= 0
	Set @Dato	= @Dato
End
Print '-------------------'
Print @FRA
Print @Dato
Print '-------------------'
If @Dato In (1) --Para Adendum
Begin
	Set @CodOficina		= Cast(Cast(SubString(@CodCuenta, 1, 3) as Int) as Varchar(4))
End
If @Dato In (3) -- Para ConsuLine
Begin
	SELECT @CodOficina = CodOficina FROM tSgUsuarios WHERE (Usuario = @Usuario)
End
Set @FechaActual	= GetDate()

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--Manejo del Sello Electronico
If @Dato In (1)	--  No se utiliza en ningún momento	el Dato = 2
Begin
	Exec pCsFirmaElectronica @Usuario, 'AH', @CodCuenta, @Firma Out	
	Print @Firma
End
If @Dato In (3)	-- ConsuLine
Begin
	Exec pCsFirmaElectronica @Usuario, 'CL', @CodCuenta, @Firma Out	
	Print @Firma
End

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--Manejo de tCsFirmaReporte.
If @Dato In (3)	-- ConsuLine
Begin
	Insert Into tCsFirmaReporte (Firma, Dato1)
	SELECT     @Firma AS Firma, CodCuenta
	FROM       vUsIdentificacion
	WHERE     (CodOrigen = @CodCuenta)
End
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--Calculo de Valores de Etiquetas.
If @Dato In (1,3)
Begin
	--[PaginaWeb]		: www.finamigo.com.mx
	SELECT    @PaginaWeb = PaginaWeb
	FROM      tClOficinas
	WHERE     (CodOficina = @CodOficina)
	--[FechaFirma]		: a los 28 días del mes de Febrero de 2010.
	Set @FechaFirma	= CASE WHEN day(GetDate()) = 1 THEN 'al primer día del mes de ' WHEN day(GetDate()) 
                      					> 1 THEN 'a los ' + cast(day(GetDate()) AS varchar(5)) + ' días del mes de ' END + dbo.fduNombreMes(MONTH(GetDate())) 
                      					+ ' de ' + dbo.fduFechaATexto(GetDate(), 'AAAA')
   --También se define los firmantes del contrato:
	If @FRA in (1) --Gerente de Agencia
	Begin
		
		--SELECT	@Firma as Firma, GerenteAgencia, 'EMP', GerenteAgencia
		--FROM		vCsResponsables
		--WHERE     (CodOficina = @CodOficina) 
	
		INSERT INTO tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto)
		SELECT @Firma as Firma, GerenteAgencia, 'EMP', GerenteAgencia
		FROM        vCsResponsables
		WHERE       (CodOficina = @CodOficina) 
	End
	If @FRA in (2) --Coordinador de Operaciones
	Begin
		INSERT INTO tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto)
		SELECT @Firma as Firma, CoordinadorOperaciones, 'EMP', CoordinadorOperaciones
		FROM		vCsResponsables
		WHERE       (CodOficina = @CodOficina) 
	End
	If @FRA in (3) --Asesor de Ahorros
	Begin
		INSERT INTO tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto)
		SELECT @Firma as Firma, AsesorAhorros, 'EMP', AsesorAhorros
		FROM            vCsResponsables
		WHERE        (CodOficina = @CodOficina) 
	End
	If @Dato In (1)
	Begin
		--[FechaApertura]: 18/05/2008 -- Se usa para apertura de Cuenta de Ahorro
		Select Distinct @FechaApertura	=	dbo.fduFechaAtexto(FechaApertura, 'DD') + '/' +
											dbo.fduFechaAtexto(FechaApertura, 'MM') + '/' +
											dbo.fduFechaAtexto(FechaApertura, 'AAAA'),
						@intTemporal	=	FormaManejo
		From tCsCboAHCA Where CodCuenta = @CodCuenta
	End	
	If @Dato In (3)
	Begin
		--[FechaApertura]: 18/05/2008 -- Se usa para Fecha de Registro del Clientes
		Select Distinct @FechaApertura	=	dbo.fduFechaAtexto(FechaIngreso, 'DD') + '/' +
											dbo.fduFechaAtexto(FechaIngreso, 'MM') + '/' +
											dbo.fduFechaAtexto(FechaIngreso, 'AAAA'),
						@intTemporal	=	1
		From vUsUsuarios Where CodUsuario = @CodCuenta
	End	
End     
--[Sujeto]			: GARCIA ARRIAGA MARIA DE LOS ANGELES, AYALA VALERIO MARTHA
--[DenoSujeto]		: El CLIENTE, LOS CLIENTES	
--[DI]				: CE : APLPTD69081115M400
--[Ahorro]			: 006-102-06-2-6-00702
--[CDireccion]		: Calle  Principal  N°  65 Col. Providencia, Mun. Alto  Lucero  De  Gutiérrez  Barrios, Edo. Veracruz  De  Ignacio  De  La  Llave C.P. 91466
Print '---------------------'
Print 'Individual/Grupal: ' + Cast(Isnull(@intTemporal, 0) As Varchar(10))
Print '---------------------'
If @Dato In (1, 3)
Begin
	If @intTemporal = 1			--Individual
	Begin
			Set @CodUsuario = @CodCuenta
			If @Dato In (1)		--Para Adendum
			Begin
				SELECT     TOP 1 @CodUsuario = vUsUsuarios.CodUsuario
				FROM       vUsUsuarios RIGHT OUTER JOIN
							  tCsCboAHCA ON vUsUsuarios.NombreCompleto = tCsCboAHCA.NombreCompleto
				WHERE     (tCsCboAHCA.CodCuenta = @CodCuenta)
			End			
			SELECT  
				@Sujeto		= NombreCompleto, 
				@DI			= CodDocIden + ': ' + DI,
				@CDireccion	= Direccion,
				@Ahorro		= IsNull(CodCuenta, @CodCuenta)
			FROM         vUsIdentificacion
			WHERE     (CodOrigen = @CodUsuario)						
			Set @SiPl		= 'S'
			Set @DenoSujeto	= 'EL CLIENTE'
			INSERT INTO tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto)
			VALUES (@Firma, @Sujeto, 'CLI', @Sujeto)
	End
End

If @Dato In (1)
Begin
	If @intTemporal In (2,3)	--Mancomunado, Solidario
	Begin
		Set @intTemporal	= 0
		Set @intTemporal1	= 0
		Set @SiPl			= 'P' 
		Set @DenoSujeto		= 'LOS CLIENTES'
	
		If @CDireccion	Is Null Begin Set @CDireccion	= '' End
		If @DI			Is Null Begin Set @DI			= '' End
		If @Ahorro		Is Null Begin Set @Ahorro		= '' End
		
		SELECT @intTemporal = Count(*) FROM ( 
		SELECT   DISTINCT  tAhUsCuenta.CodUsCuenta, tUsUsuarios.NombreCompleto
		FROM         [BD-FINAMIGO-DC].Finmas.dbo.tAhUsCuenta tAhUsCuenta INNER JOIN
							  [BD-FINAMIGO-DC].Finmas.dbo.tUsUsuarios tUsUsuarios ON tAhUsCuenta.CodUsCuenta = tUsUsuarios.CodUsuario
		WHERE     (tAhUsCuenta.idEstado = 'AC') AND (tAhUsCuenta.CodCuenta = @CodCuenta)) Datos
		
		SELECT @intTemporal1 = Count(*) FROM ( 
		SELECT   DISTINCT  tCsClientesAhorrosFecha.CodCuenta, tCsClientesAhorrosFecha.CodUsCuenta, tCsPadronClientes.NombreCompleto
		FROM         tCsClientesAhorrosFecha INNER JOIN
							  vCsFechaConsolidacion ON tCsClientesAhorrosFecha.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN
							  tCsPadronClientes ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
		WHERE     (tCsClientesAhorrosFecha.CodCuenta = @CodCuenta)) Datos
		
		If @intTemporal >=  @intTemporal1
		Begin
			Insert Into #Sujeto
			SELECT   DISTINCT  tAhUsCuenta.CodUsCuenta, tUsUsuarios.NombreCompleto
			FROM         [BD-FINAMIGO-DC].Finmas.dbo.tAhUsCuenta tAhUsCuenta INNER JOIN
								  [BD-FINAMIGO-DC].Finmas.dbo.tUsUsuarios tUsUsuarios ON tAhUsCuenta.CodUsCuenta = tUsUsuarios.CodUsuario
			WHERE     (tAhUsCuenta.idEstado = 'AC') AND (tAhUsCuenta.CodCuenta = @CodCuenta)
			Set @intTemporal1 = @intTemporal
		End	
		If @intTemporal1 >  @intTemporal
		Begin
			Insert Into #Sujeto
			SELECT   DISTINCT  tCsClientesAhorrosFecha.CodUsCuenta, tCsPadronClientes.NombreCompleto
			FROM         tCsClientesAhorrosFecha INNER JOIN
								  vCsFechaConsolidacion ON tCsClientesAhorrosFecha.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN
								  tCsPadronClientes ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
			WHERE     (tCsClientesAhorrosFecha.CodCuenta = @CodCuenta)
			Set @intTemporal1 = @intTemporal1
		End	
		Set @intTemporal	= 0
		Set @Sujeto			= ''
		Declare curReporte Cursor For 
			Select Sujeto From #Sujeto		
		Open curReporte
		Fetch Next From curReporte Into @vcrTemporal
		While @@Fetch_Status = 0
		Begin 	
			INSERT INTO tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto)
			VALUES (@Firma, @vcrTemporal, 'CLI', @vcrTemporal)
			Set @intTemporal 	= @intTemporal + 1
			If  @intTemporal 	= @intTemporal1
			Begin
				Set @Sujeto 	= @Sujeto + ' Y ' +	Ltrim(Rtrim(@vcrTemporal))
			End
			Else
			Begin
				Set @Sujeto 	= @Sujeto + ', ' +	Ltrim(Rtrim(@vcrTemporal))	
			End			
		Fetch Next From curReporte Into  @vcrTemporal
		End 
		Close 		curReporte
		Deallocate 	curReporte
		Set @Sujeto 	= Substring(Ltrim(@Sujeto), 3, 1000)
	End
	/*
	Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
	Print 'Hora			: ' + Cast(datepart(Hour,			getdate())	as Varchar(10))
	Print 'Minuto			: ' + Cast(datepart(Minute,			getdate())	as Varchar(10))
	Print 'Segundo			: ' + Cast(datepart(Second,			getdate())	as Varchar(10))
	Print 'Microsegundo	: ' + Cast(datepart(Millisecond,	getdate())	as Varchar(10))
	Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
	*/
	--[CreditosV]		: [Nro: 006-116-06-00-01295 de fecha 18/05/2007] Y [Nro: 006-121-06-02-00536 de fecha 02/06/2007]
	Select @intTemporal1 = Count(*) From (
	SELECT DISTINCT '[Nro: ' + CodPrestamo + ' de fecha ' + dbo.fduFechaATexto(FechaDesembolso, 'DD') + '/' + dbo.fduFechaATexto(FechaDesembolso, 'MM') 
						  + '/' + dbo.fduFechaATexto(FechaDesembolso, 'AAAA') + ']' AS Credito
	FROM         tCsCboAHCA
	WHERE     (CodCuenta = @CodCuenta)) Datos	
	Set @intTemporal	= 0
	Set @CreditosV		= ''
	Declare curReporte Cursor For 
		SELECT DISTINCT '[Nro: ' + CodPrestamo + ' de fecha ' + dbo.fduFechaATexto(FechaDesembolso, 'DD') + '/' + dbo.fduFechaATexto(FechaDesembolso, 'MM') 
							  + '/' + dbo.fduFechaATexto(FechaDesembolso, 'AAAA') + ']' AS Credito
		FROM         tCsCboAHCA
		WHERE     (CodCuenta = @CodCuenta)		
	Open curReporte
	Fetch Next From curReporte Into @vcrTemporal
	While @@Fetch_Status = 0
	Begin 	
		Set @intTemporal 	= @intTemporal + 1
		If  @intTemporal 	= @intTemporal1
		Begin
			Set @CreditosV 	= @CreditosV + ' y ' +	Ltrim(Rtrim(@vcrTemporal))
		End
		Else
		Begin
			Set @CreditosV 	= @CreditosV + ', ' +	Ltrim(Rtrim(@vcrTemporal))	
		End			
	Fetch Next From curReporte Into  @vcrTemporal
	End 
	Close 		curReporte
	Deallocate 	curReporte
	Set @CreditosV 	= Substring(Ltrim(@CreditosV), 3, 1000)
	If @intTemporal1 > 1
	Begin
		Set @CreditosV 	= 'de los creditos ' + @CreditosV
	End
	If @intTemporal1 = 1
	Begin
		Set @CreditosV 	= 'del crédito ' + @CreditosV
	End	
End
Set @CreditosV = Isnull(@CreditosV, '')
If @Dato In (1, 3)
Begin
	--[ODireccion]		: Calle Nicolas Bravo S/N., Ixtlahuaca de Rayón, Municipio de Ixtlahuaca, Estado de México, C.P. 50740
	Select @vcrTemporal = Tipo From tClOficinas
	Where CodOficina = @CodOficina
	
	Truncate Table #Oficina
	Insert Into #Oficina
	Exec pCsOficinasDireccion @vcrTemporal , @FechaActual
	Set @Cadena = ''
	Declare curReporte Cursor For 
		Select Direccion 
		From #Oficina
		Where CodOficina = @CodOficina And Direccion Is not Null
		Order by Orden
	Open curReporte
	Fetch Next From curReporte Into @TempVC
	While @@Fetch_Status = 0
	Begin 	
		Set @Cadena = @Cadena + ', ' +	Ltrim(Rtrim(@TempVC))
	Fetch Next From curReporte Into  @TempVC
	End 
	Close 		curReporte
	Deallocate 	curReporte
	
	Set @ODireccion	= Substring(Ltrim(Rtrim(@Cadena)), 3, 1000)
	
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	--Registro de Valores de Etiquetas.
	Set @intTemporal = 0
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[CodCuenta]', 		@CodCuenta		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[Sujeto]', 			@Sujeto			) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[DenoSujeto]', 		@DenoSujeto		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[FechaApertura]', 	@FechaApertura	) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[CreditosV]', 		@CreditosV		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[ODireccion]', 		@ODireccion		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[CDireccion]', 		@CDireccion		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[FechaFirma]', 		@FechaFirma		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[DI]',				@DI				) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[PaginaWeb]',		@PaginaWeb		) Set @intTemporal = @intTemporal + 1
	Insert Into #Etiqueta (Fila, Etiqueta, Texto)	Values (@intTemporal, '[Ahorro]',			@Ahorro			) Set @intTemporal = @intTemporal + 1
	
	--Select * From #Etiqueta
	
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	--Calculo de Clausulas.
	Declare curReporte2 Cursor For 
		SELECT DISTINCT Tipo
		FROM        tCsRPTClausulas Where Activo = 1 And 
					(Tipo like 'AdendumAhorros%' Or Tipo like 'ConsuLine%')
	Open curReporte2
	Fetch Next From curReporte2 Into @TipoClausula
	While @@Fetch_Status = 0
	Begin 				
		Set @Cadena 	= ''		
		Set @Contador 	= 0

		Declare curReporte Cursor For 
			Select 	Rtrim(Ltrim(Isnull(Condicion, ''))), Orden, Titulo, Isnull(Texto1, '') + IsNUll(Texto2, '') as Cadena, Tipo, 
				IsNull(TAdicional, '') As TAdicional, IsNull(DAdicional, '') As DAdicional
			From tCsRPTClausulas Where Tipo = @TipoClausula And Activo = 1
			Order by Orden
		Open curReporte
		Fetch Next From curReporte Into @TempVC, @TempIT, @OtroDato, @Cadena, @TempVC6, @TempVC7, @TempVC8
		While @@Fetch_Status = 0
		Begin 	
			Print '@TempVC	: ' + Isnull(@TempVC,	'Nulo')	
			Print 'OtroDato	: ' + Isnull(@OtroDato, 'Nulo')
			Print 'Cadena	: ' + Isnull(@Cadena,	'Nulo')	
			If @TempVC <> ''
			Begin
				Truncate Table #Valor
				Set @TempVC3 = 'Insert Into #Valor (Valor) SELECT COUNT(*) '
				Set @TempVC3 = @TempVC3 + 'FROM tCsFirmaElectronica INNER JOIN '
              				Set @TempVC3 = @TempVC3 + 'tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN '
              				Set @TempVC3 = @TempVC3 + 'tCaProducto ON tCsFirmaReporte.Dato4 = tCaProducto.CodProducto LEFT OUTER JOIN '
              				Set @TempVC3 = @TempVC3 + '(SELECT * FROM tCsCartera WHERE Fecha IN (SELECT Fechaconsolidacion FROM vcsfechaconsolidacion)) '
				Set @TempVC3 = @TempVC3 + 'tCsCartera ON tCsFirmaElectronica.Dato = tCsCartera.CodPrestamo '
				Set @TempVC3 = @TempVC3 + 'WHERE (tCsFirmaElectronica.Firma = ''' + @Firma + ''') AND ' + @TempVC
				--Print 'KEMY: ' + @TempVC3
				Exec(@TempVC3)
				Select @TempVC3 = Valor From #Valor 
				--Print @TempVC3
				If Cast(@TempVC3 As Int) > 0
				Begin
					Set @Mayuscula = 1
				End
				Else
				Begin
					Set @Mayuscula = 0
				End
			End 
			Else
			Begin
				Set @Mayuscula = 1
			End
			If @Mayuscula = 1
			Begin
				Set @Contador = @Contador + 1
				--Se reemplaza etiquetas
				Declare curReporte1 Cursor For 
					Select Etiqueta, Texto
					From #Etiqueta
				Open curReporte1
				Fetch Next From curReporte1 Into @TempVC4, @TempVC5
				While @@Fetch_Status = 0
				Begin 	
					--Print 'OtroDato	: ' + Isnull(@OtroDato, 'Nulo')
					--Print 'Cadena	: ' + Isnull(@Cadena, 'Nulo')	
					--Print '@TempVC4	: ' + Isnull(@TempVC4, 'Nulo')
					--Print '@TempVC5	: ' + Isnull(@TempVC5, 'Nulo')	
					
					Set @Cadena 	= Replace(@Cadena, 	@TempVC4, @TempVC5)
					Set @OtroDato 	= Replace(@OtroDato, 	@TempVC4, @TempVC5)
					Set @TempVC7 	= Replace(@TempVC7, 	@TempVC4, @TempVC5)
				Fetch Next From curReporte1 Into @TempVC4, 	@TempVC5
				End 
				Close 		curReporte1
				Deallocate 	curReporte1					
				
				Print 'VEREMOS SI LA CLAUSULA NECESITA DE TEXTO ADICIONAL'
				Print 	CharIndex('{Adicional}', @Cadena, 1)
				Print 	@TempVC7
				Print 	@TempVC8				   
				If 	CharIndex('{Adicional}', @Cadena, 1) 	<> 0 	And
					@TempVC7 				<> '' 	And
					@TempVC8 				<> '' 	
				Begin
					Truncate Table #Valor
					Set @TempVC2 = 'Insert Into #Valor(Valor) Select ' + @TempVC8 + ' From '
					Set @TempVC2 = @TempVC2 + SubString(@TempVC8, 1, CharIndex('.', @TempVC8, 1) - 1) + ' '
					Set @TempVC2 = @TempVC2 + 'Where Firma = ''' + @Firma + ''''
					Exec(@TempVC2)
					Set @TempVC2 = ''
					Select @TempVC2 = Valor From #Valor  
					If @TempVC2 Is null Begin Set @TempVC2 = '' end
					If @TempVC2 = ''
					Begin
						Set @TempVC7 = ''
					End
				End
				Else
				Begin
					Set @TempVC7 = ''
				End			
				
				Print 'VALIDA ERROR DE DATO 1'
				Print 'Firma	: ' + Isnull(@Firma, 'Nulo')
				Print 'Contador	: ' + Isnull(Cast(@Contador as Varchar(10)), 'Nulo')
				Print 'Ordinal	: ' + IsNull(dbo.fduNumeroOrdinal(@Contador), 'Nulo')
				Print 'TempIT	: ' + Cast(@TempIT as Varchar(10))
				Print 'OtroDato	: ' + Isnull(@OtroDato, 'Nulo')
				Print 'Cadena	: ' + Isnull(@Cadena, 'Nulo')
				Print 'TempVC6	: ' + Isnull(@TempVC6, 'Nulo')					

				Set @Cadena 	= Replace(@Cadena,'{Adicional}', @TempVC7) 
				Set @Cadena 	= Replace(@Cadena, '  ', ' ')
				Set @OtroDato 	= Replace(@OtroDato, '  ', ' ')
				Set @Cadena 	= Replace(@Cadena, Char(10)+''+Char(10), '')
				Set @OtroDato 	= Replace(@OtroDato, Char(10)+''+Char(10), '')		
				Set @Cadena 	= Replace(@Cadena, ''+char(10)+char(13)+'', '')
				Set @OtroDato	= Replace(@OtroDato, ''+char(10)+char(13)+'', '')			
				Set @Cadena 	= Replace(@Cadena, ''+char(10)+'.', '.')
				Set @OtroDato	= Replace(@OtroDato, ''+char(10)+'.', '.')						
				Set @Cadena 	= Replace(@Cadena, ''+char(10)+',', ',')
				Set @OtroDato	= Replace(@OtroDato, ''+char(10)+',', ',')
				
				Print 'VALIDA ERROR DE DATO 2'
				Print 'Firma	: ' + Isnull(@Firma, 'Nulo')
				Print 'Contador	: ' + Isnull(Cast(@Contador as Varchar(10)), 'Nulo')
				Print 'Ordinal	: ' + IsNull(dbo.fduNumeroOrdinal(@Contador), 'Nulo')
				Print 'TempIT	: ' + Cast(@TempIT as Varchar(10))
				Print 'OtroDato	: ' + Isnull(@OtroDato, 'Nulo')
				Print 'Cadena	: ' + Isnull(@Cadena, 'Nulo')
				Print 'TempVC6	: ' + Isnull(@TempVC6, 'Nulo')	
		
				--Se identifica si se trata de una solicitud que hace referencia a Un cliente o Varios
				Exec pCsSingularPlural @SiPl, @Cadena, @TempVC1 Out
				Set @Cadena = @TempVC1
				Exec pCsSingularPlural @SiPl, @OtroDato, @TempVC1 Out
				Set @OtroDato = @TempVC1			
				
				Print 'VALIDA ERROR DE DATO 3'
				Print 'Firma	: ' + Isnull(@Firma, 'Nulo')
				Print 'Contador	: ' + Isnull(Cast(@Contador as Varchar(10)), 'Nulo')
				Print 'Ordinal	: ' + IsNull(dbo.fduNumeroOrdinal(@Contador), 'Nulo')
				Print 'TempIT	: ' + Cast(@TempIT as Varchar(10))
				Print 'OtroDato	: ' + Isnull(@OtroDato, 'Nulo')
				Print 'Cadena	: ' + Isnull(@Cadena, 'Nulo')
				Print 'TempVC6	: ' + Isnull(@TempVC6, 'Nulo')
				Insert Into tCsFirmaReporteClausula (Firma, Fila, Clausula, Orden, Titulo, Texto, Tipo)
				Values(@Firma, @Contador, dbo.fduNumeroOrdinal(@Contador), @TempIT, @OtroDato, @Cadena, @TempVC6)	
			End
		Fetch Next From curReporte Into  @TempVC, @TempIT, @OtroDato, @Cadena, @TempVC6, @TempVC7, @TempVC8
		End 
		Close 		curReporte
		Deallocate 	curReporte	

	Fetch Next From curReporte2 Into  @TipoClausula
	End 
	Close 		curReporte2
	Deallocate 	curReporte2	

	/*
	Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
	Print 'Hora			: ' + Cast(datepart(Hour,			getdate())	as Varchar(10))
	Print 'Minuto			: ' + Cast(datepart(Minute,			getdate())	as Varchar(10))
	Print 'Segundo			: ' + Cast(datepart(Second,			getdate())	as Varchar(10))
	Print 'Microsegundo	: ' + Cast(datepart(Millisecond,	getdate())	as Varchar(10))
	Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
	--*/

	SELECT  @Contador = COUNT(*) 
	FROM         tCsFirmaReporteClausula
	WHERE     (Texto LIKE '%[ [ ]clausula:%') AND (tCsFirmaReporteClausula.Firma = @Firma)

	WHILE @Contador > 0
	Begin
		UPDATE    tCsFirmaReporteClausula
		SET              texto = REPLACE(tCsFirmaReporteClausula.Texto, SUBSTRING(tCsFirmaReporteClausula.Texto, CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1), 
							  CHARINDEX(']', tCsFirmaReporteClausula.Texto, CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1)) - CHARINDEX('[Clausula:', 
							  tCsFirmaReporteClausula.Texto, 1) + 1), UPPER(tCsFirmaReporteClausula_1.Clausula))
		FROM         tCsFirmaReporteClausula INNER JOIN
							  tCsFirmaReporteClausula tCsFirmaReporteClausula_1 ON tCsFirmaReporteClausula.Firma = tCsFirmaReporteClausula_1.Firma AND 
							  SUBSTRING(tCsFirmaReporteClausula.Texto, CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1) + 10, CHARINDEX(']', tCsFirmaReporteClausula.Texto, 
							  CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1)) - CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1) - 10) 
							  = tCsFirmaReporteClausula_1.Titulo
		WHERE (tCsFirmaReporteClausula.Firma = @Firma) AND (tCsFirmaReporteClausula.Texto LIKE '%[ [ ]clausula:%')	
		
		SELECT  @Contador = COUNT(*) 
		FROM         tCsFirmaReporteClausula
		WHERE     (Texto LIKE '%[ [ ]clausula:%') AND (tCsFirmaReporteClausula.Firma = @Firma)
		
	End  	
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	--Selección de Datos y Registro de Firma 
	
	If @Dato in (1)
	Begin
		DELETE FROM tCsFirmaDocumentos WHERE CodSistema = 'AH' AND Cuenta = @CodCuenta AND Tipo = 'Adendum Ahorros'
		INSERT INTO tCsFirmaDocumentos VALUES(@CodOficina, 'AH', @CodCuenta, 'Adendum Ahorros', @Firma)		
			
		Insert Into [BD-FINAMIGO-DC].Finmas.dbo.tCsCadenaExec (Tipo, Registro, Cadena, Activo)
		Values ('ADE', GetDate(), 'UPDATE tahCuenta Set Adendum = ''' + @Firma + ''' Where CodCuenta = ''' + @CodCuenta + '''', 1)
				
		--Set @vcrTemporal = 'Update tAhCuenta Set Adendum = '''+ @Firma +''' Where CodCuenta = '''+ @CodCuenta +''''
		  	
		SELECT        Declaracion.Firma, Declaracion.CodCuenta, Clausulas.Clausula, Clausulas.Orden, Declaracion.Declaracion, Clausulas.Clausulas
		FROM            (SELECT        tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato AS CodCuenta, tCsFirmaReporteClausula.Clausula, tCsFirmaReporteClausula.Orden, 
															tCsFirmaReporteClausula.Titulo, tCsFirmaReporteClausula.Texto AS Clausulas
								  FROM            tCsFirmaElectronica INNER JOIN
															tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma
								  WHERE        (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Dato = @CodCuenta) AND 
															(tCsFirmaReporteClausula.Tipo = 'AdendumAhorros2')) AS Clausulas INNER JOIN
									 (SELECT        tCsFirmaElectronica_1.Firma, tCsFirmaElectronica_1.Dato AS CodCuenta, tCsFirmaReporteClausula_1.Clausula, tCsFirmaReporteClausula_1.Orden, 
																 tCsFirmaReporteClausula_1.Titulo, tCsFirmaReporteClausula_1.Texto AS Declaracion
									   FROM            tCsFirmaElectronica AS tCsFirmaElectronica_1 INNER JOIN
																 tCsFirmaReporteClausula AS tCsFirmaReporteClausula_1 ON tCsFirmaElectronica_1.Firma = tCsFirmaReporteClausula_1.Firma
									   WHERE        (tCsFirmaElectronica_1.Usuario = @Usuario) AND (tCsFirmaElectronica_1.Activo = 1) AND (tCsFirmaElectronica_1.Dato = @CodCuenta) AND 
																 (tCsFirmaReporteClausula_1.Tipo = 'AdendumAhorros1')) AS Declaracion ON Clausulas.Firma = Declaracion.Firma AND 
								 Clausulas.CodCuenta = Declaracion.CodCuenta
		
	End
	If @Dato in (3)
	Begin
		DELETE FROM tCsFirmaDocumentos WHERE CodSistema = 'CL' AND Cuenta = @CodCuenta AND Tipo = 'ConsuLine'
		INSERT INTO tCsFirmaDocumentos VALUES(@CodOficina, 'CL', @CodCuenta, 'ConsuLine', @Firma)
		SELECT        Declaracion.Firma, Declaracion.CodCuenta, Clausulas.Clausula, Clausulas.Orden, Declaracion.Declaracion, Clausulas.Clausulas
		FROM            (SELECT        tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato AS CodCuenta, tCsFirmaReporteClausula.Clausula, tCsFirmaReporteClausula.Orden, 
															tCsFirmaReporteClausula.Titulo, tCsFirmaReporteClausula.Texto AS Clausulas
								  FROM            tCsFirmaElectronica INNER JOIN
															tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma
								  WHERE        (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Dato = @CodCuenta) AND 
															(tCsFirmaReporteClausula.Tipo = 'ConsuLine2')) AS Clausulas INNER JOIN
									 (SELECT        tCsFirmaElectronica_1.Firma, tCsFirmaElectronica_1.Dato AS CodCuenta, tCsFirmaReporteClausula_1.Clausula, tCsFirmaReporteClausula_1.Orden, 
																 tCsFirmaReporteClausula_1.Titulo, tCsFirmaReporteClausula_1.Texto AS Declaracion
									   FROM            tCsFirmaElectronica AS tCsFirmaElectronica_1 INNER JOIN
																 tCsFirmaReporteClausula AS tCsFirmaReporteClausula_1 ON tCsFirmaElectronica_1.Firma = tCsFirmaReporteClausula_1.Firma
									   WHERE        (tCsFirmaElectronica_1.Usuario = @Usuario) AND (tCsFirmaElectronica_1.Activo = 1) AND (tCsFirmaElectronica_1.Dato = @CodCuenta) AND 
																 (tCsFirmaReporteClausula_1.Tipo = 'ConsuLine1')) AS Declaracion ON Clausulas.Firma = Declaracion.Firma AND 
								 Clausulas.CodCuenta = Declaracion.CodCuenta
	End
End 
If @Dato In (2)
Begin                   
	SELECT     tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato AS CodCuenta, 
						  CASE tCsFirmaReporteDetalle.Grupo WHEN 'CLI' THEN 'CLIENTE' WHEN 'EMP' THEN 'FINAMIGO' END AS Grupo, tCsFirmaReporteDetalle.Sujeto
	FROM         tCsFirmaElectronica INNER JOIN
						  tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	WHERE     (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Dato = @CodCuenta)
	ORDER BY tCsFirmaReporteDetalle.Grupo                         
End                      
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--Eliminacion de Tablas Temporales.
Drop Table #Sujeto
Drop Table #Etiqueta
Drop Table #Valor
Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'
Print 'Hora			: ' + Cast(datepart(Hour,			getdate())	as Varchar(10))
Print 'Minuto			: ' + Cast(datepart(Minute,			getdate())	as Varchar(10))
Print 'Segundo			: ' + Cast(datepart(Second,			getdate())	as Varchar(10))
Print 'Microsegundo	: ' + Cast(datepart(Millisecond,	getdate())	as Varchar(10))
Print '<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>-----<>'




GO