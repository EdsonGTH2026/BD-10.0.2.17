SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsRptCaSituacionCarteraVertical
--Exec pCsRptCaSituacionCarteraVertical 2, '20110531', 'ZZZ', 'Tecnologia', 'Oficina', 'ACTIVA', '01', 'CA01', ''
CREATE Procedure [dbo].[pCsRptCaSituacionCarteraVertical]
@Dato			Int,
@Fecha 			SmallDateTime,
@Ubicacion		Varchar(100),
@Nivel1			Varchar(50),
@Nivel2			Varchar(50),
@ClaseCartera	Varchar(100),	
@TipoSaldo		Varchar(1000),
@Reporte 		Varchar(50) = 'oo',
@Usuario		Varchar(25) = 'kvalera'
As

Print '-----------------------------------------'
Print 'HORA INICIO: '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'

Declare @UBI		Varchar(100)
Declare @CCA		Varchar(100)
Declare @TSA		Varchar(1000)

Set @UBI	= @Ubicacion 
Set @CCA	= @ClaseCartera
Set @TSA	= @TipoSaldo

--Declare @Reporte 	Varchar(50)
Declare @ID			Varchar(50)
Declare @TempI		Int

Declare @IDp1		Varchar(50)
Declare @IDp2		Varchar(50)
Declare @IDp3		Varchar(50)
Declare @IDp4		Varchar(50)
Declare @IDp5		Varchar(50)
Declare @IDp6		Varchar(50)
Declare @IDp7		Varchar(50)
Declare @IDp8		Varchar(50)

--Set @Reporte 	= 'CA01'
Set @IDp1 	= dbo.fduFechaATexto(@Fecha, 'AAAAMMDD')
Set @IDp2	= @Ubicacion
Set @IDp3 	= @Nivel1
Set @IDp4 	= @Nivel2
Set @IDp5 	= @ClaseCartera
Set @IDp6 	= @TipoSaldo
Set @IDp7 	= @Reporte
Set @IDp8 	= @Usuario

Declare @Cadena			Varchar(4000)
Declare @Cadena1		Varchar(4000)
Declare @Cadena2		Varchar(4000)
Declare @Cadena3		Varchar(4000)
Declare @CDetalle1 		Varchar(8000)
Declare @CDetalle2 		Varchar(8000)
Declare @CDetalle3 		Varchar(8000)
Declare @CDetalle4 		Varchar(8000)
Declare @CPrincipal1 	Varchar(4000)
Declare @CPrincipal2 	Varchar(4000)
Declare @CPrincipal3 	Varchar(4000)
Declare @CPrincipal4 	Varchar(4000)
Declare @Concepto		Varchar(100)
Declare @CConceptos1 	Varchar(8000)
Declare @CConceptos2 	Varchar(8000)
Declare @CConceptos3 	Varchar(8000)
Declare @CConceptos4 	Varchar(8000)
Declare @Select			Varchar(2000)
Declare @Select1		Varchar(2000)
Declare @GroupBy		Varchar(2000)
Declare @GroupBy1		Varchar(2000)
Declare @Identificador	Varchar(10)
Declare @ICampo			Varchar(100)
Declare @IGrupo			Varchar(100)
Declare @Campo			Varchar(4000)
Declare @Sumatoria		Varchar(4000)

Declare @CUbicacion		Varchar(1500)
Declare @CClaseCartera	Varchar(500)

Declare @Tabla 			Varchar(50)
Declare @DSelect		Varchar(8000)
Declare @DFrom1			Varchar(8000)
Declare @DFrom2			Varchar(8000)
Declare @DFrom3			Varchar(8000)
Declare @DWhere			Varchar(8000)
Declare @DGroupBy		Varchar(8000)

Declare @OtroDato		Varchar(100)
Declare @CampoRango		Varchar(500)
Declare @Temp			Varchar(4000)
Declare @AvanceV		Varchar(100)			

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out

If @Reporte = 'oo' 
Begin
	Exec pGnlCalculaParametros 6, @TipoSaldo, 	@Reporte 	Out, 	@Cadena 	Out,  @Cadena1 Out
End

If Substring(@Reporte, 1, 2)  In ('CA')
Begin
	Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out
End
If Substring(@Reporte, 1, 2)  In ('AH')
Begin
	Exec pGnlCalculaParametros 5, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out
End
Exec pGnlCalculaParametros 3, @IDp6, 	@TipoSaldo 	Out, 	@Tabla 	Out,  @OtroDato Out

Print 'OTRO DATO: ' + @OtroDato

--------------------------------------------------------------------------------------------------------------------------------------------------------
--CODIGO QUE REGISTRA PARAMETROS DE REPORTE CON SU RESPECTIVO ID
Declare @FactorID Int
Set @FactorID 	= 10

SELECT  @TempI =	Ascii(SUBSTRING(LTRIM(RTRIM(Usuario)), 1, 1)) + 
					Ascii(SUBSTRING(LTRIM(RTRIM(Usuario)), LEN(LTRIM(RTRIM(Usuario))) / 2, 1)) + 
					Ascii(RIGHT(LTRIM(RTRIM(Usuario)), 1))
FROM  	tSgUsuarios
WHERE 	Usuario = @Usuario

Print 'Usuario: ' + isnull(@Usuario, 'Nulo')
Print Isnull(@TempI, 0)

Set @ID 	=   	
			SUBSTRING(dbo.fduNumeroALetras(DATEPART(Day, 	@Fecha), 0), 1, 1) +
			SUBSTRING(dbo.fduNumeroALetras(DATEPART(Month, 	@Fecha), 0), 1, 1) +
			SUBSTRING(dbo.fduNumeroALetras(Cast(dbo.fduFechaATexto(@Fecha, 'AA') as Int), 0), 1, 1) +
			SUBSTRING(@Ubicacion, 	1, 1) + 
			SUBSTRING(@Nivel1, 		1, 1) + 
			SUBSTRING(@Nivel2, 		1, 1) + 
			SUBSTRING(@ClaseCartera,	1, 1) + 
			SUBSTRING(dbo.fduNumeroALetras(Cast(@IDp6 as int), 0), 1, 1) + '-' 	+ 
			Cast((	DATEPART(Day, @Fecha) 		+ 
				DATEPART(Month, @Fecha) 		+ 
				DATEPART(Year,  @Fecha) 		+ 
				Len(@CUbicacion) * (@FactorID + 1)	+ 
				Ascii(SUBSTRING(@NIvel1, 1, 1)) 	+ 
				Ascii(SUBSTRING(@NIvel2, 1, 1)) 	+ 
				Len(@CClaseCartera) 			+ 
				Len(@TipoSaldo) + (Cast(@IDp6 as int) * (@FactorID + 1)) + 
				Ascii(Substring(@Reporte, 1, 1))		+
				Ascii(Substring(@Reporte, 2, 1))		+
				Ascii(Substring(@Reporte, 3, 1))		+
				Ascii(Substring(@Reporte, 4, 1)) +	@TempI) % @FactorID as Varchar(2))

Exec pCsRptID @ID,  '@Usuario',  	@Reporte, @IDp8
Exec pCsRptID @ID,  '@Fecha',  		@Reporte, @IDp1
Exec pCsRptID @ID,  '@Ubicacion',  	@Reporte, @IDp2	
Exec pCsRptID @ID,  '@Nivel1',  	@Reporte, @IDp3
Exec pCsRptID @ID,  '@Nivel2',  	@Reporte, @IDp4	
Exec pCsRptID @ID,  '@ClaseCartera',@Reporte, @IDp5	
Exec pCsRptID @ID,  '@TipoSaldo',  	@Reporte, @IDp6	
Exec pCsRptID @ID,  '@Reporte',  	@Reporte, @IDp7


--------------------------------------------------------------------------------------------------------------------------------------------------------
Exec pCsRptCaDetalleCartera 	@Fecha, @CUbicacion, @Ubicacion, @CClaseCartera, @ClaseCartera, @Tabla,
				@DSelect 	Out,
				@DFrom1		Out,
				@DFrom2		Out,
				@DFrom3		Out,
				@DWhere 	Out,
				@DGroupBy	Out,
				@Usuario	

Set @Select 	=  'SELECT Detalle.Cartera, Detalle.Ubicacion, Detalle.Fecha, tCsPrReportesAnexos.Reporte, '
Set @Select 	=  @Select + 'tCsPrReportesAnexos.Identificador, Detalle.'+ @Nivel2 +' AS Nivel2 '

Set @GroupBy	= 'GROUP BY Detalle.Cartera, Detalle.Ubicacion, Detalle.Fecha, tCsPrReportesAnexos.Identificador, '
Set @GroupBy	= @GroupBy  + 'tCsPrReportesAnexos.Reporte, Detalle.'+ @Nivel2 +' '

If @Dato in (1, 3)
Begin
	Set @Select 	= @Select + ', Detalle.'+ @Nivel1 +' AS Nivel1 '
	Set @GroupBy	= @GroupBy  + ', Detalle.'+ @Nivel1 + ' ' 
End
If @Dato = 2
Begin
	Set @Select 	= @Select + ', ''RESUMEN'' As Nivel1 '
End

SELECT   @CampoRango = CampoRango
FROM         tCsPrReporte
WHERE     (Reporte = @Reporte)

If Charindex('@', @CampoRango, 1) > 0 
Begin
	--CREATE TABLE #CampoRango (
	--[CampoDato] [varchar] (4000) COLLATE Modern_Spanish_CI_AI NULL) 

	--Set @Temp = 'Insert Into #CampoRango (CampoDato) Values (' +  @Campodato +  ''	

	--Set @Temp = 'Set @CampoRango = ' +  Replace(@CampoRango)
	--Exec (@Temp)
	Print 'CAMPO RANGO : ' + @CampoRango
	--Drop Table #CampoRango
End

Set @CDetalle1 		=  'FROM tCsPrReportesAnexos INNER JOIN ( '  +  @DSelect + @DFrom1 
Set @CDetalle2 		=  @DFrom2 
Set @CDetalle4 		=  @DFrom3 
Set @CDetalle3 		=  @DWhere + @DGroupBy + ') Detalle ON tCsPrReportesAnexos.pInicio <= ('+ @CampoRango +') AND tCsPrReportesAnexos.PFin >= ('+ @CampoRango +') WHERE (tCsPrReportesAnexos.Reporte = '''+ @Reporte +''') '

Print 'CDetalle1 = ' + Cast(Len(@CDetalle1) as Varchar(100))
Print 'CDetalle2 = ' + Cast(Len(@CDetalle2) as Varchar(100))
Print 'CDetalle3 = ' + Cast(Len(@CDetalle3) as Varchar(100))
Print 'CDetalle4 = ' + Cast(Len(@CDetalle4) as Varchar(100))

-- CONSULTA PRINCIPAL
Set @Select1 		= ', tCsPrReportesAnexos.Descripcion AS CampoReporte, tCsPrReportesAnexos.DescIdentificador AS GrupoReporte, '
Set @Select1 		=  @Select1 + 'SUM(Detalle.Desembolso) AS Desembolso, '
Set @Select1 		=  @Select1 + 'SUM('+ @TipoSaldo +') AS Saldo '

Set @GroupBy1 	= ', tCsPrReportesAnexos.Descripcion, tCsPrReportesAnexos.DescIdentificador '

Set @CPrincipal1 	=  @Select		+ @Select1  
Set @CPrincipal2 	=  @CDetalle2
Set @CPrincipal4 	=  @CDetalle4
Set @CPrincipal3 	=  @CDetalle3	+ @GroupBy + @GroupBy1

Print '-----------------------------------------'
Print 'HORA MITAD: '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'

Print 'CONSULTA PRINCIPAL'
Print @CPrincipal1
Print @CPrincipal2
Print @CPrincipal4
Print @CPrincipal3

CREATE TABLE #tRptSituacionCarteraContador (
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha] [smalldatetime] NULL ,
	[Nivel1] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel2] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Reporte] [varchar] (5) COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] [varchar] (10) COLLATE Modern_Spanish_CI_AI NULL ,
	[Concepto] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL ,
	[Contador] [int] NULL )

-- PARA CONTAR CLIENTES Y PRESTAMOS	
Set @Concepto	= 'CodUsuario'
Set @Select1 	= ', Detalle.' + @Concepto + ' '
Set @GroupBy1	= ', Detalle.' + @Concepto

Print 'Tamaño de @Select + @Select1 + @CDetalle1 = ' + Cast(Len(@Select + @Select1 + @CDetalle1) as Varchar(100)) 

Set @CConceptos1  	= 'Insert Into #tRptSituacionCarteraContador SELECT Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, Concepto = '''+ @Concepto +''', COUNT(*) AS Contador FROM ( ' + @Select + @Select1 
Set @CConceptos2	= @CDetalle2  
Set @CConceptos4	= @CDetalle4  
Set @CConceptos3	= @CDetalle3 + @GroupBy + @GroupBy1 + ')' + @Concepto + ' GROUP BY Cartera, Fecha, Nivel1, Nivel2, reporte, Identificador '

Print 	'CONTANDO CLIENTES'
Print  	@CConceptos1 
Print 	@CDetalle1
Print 	@CConceptos2 
Print 	@CConceptos4
Print 	@CConceptos3

Print '@CConceptos1 = ' + Cast(Len(@CConceptos1) as Varchar(100))
Print '@CConceptos2 = ' + Cast(Len(@CConceptos2) as Varchar(100))
Print '@CConceptos3 = ' + Cast(Len(@CConceptos3) as Varchar(100))
Print '@CConceptos4 = ' + Cast(Len(@CConceptos4) as Varchar(100))

Exec    (@CConceptos1 + @CDetalle1 + @CConceptos2 + @CConceptos4 + @CConceptos3)

Set @Concepto	= 'CodPrestamo'
Set @Select1 	= ', Detalle.' + @Concepto + ' '
Set @GroupBy1 = ', Detalle.' + @Concepto

Set @CConceptos1  	= 'Insert Into #tRptSituacionCarteraContador SELECT Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, Concepto = '''+ @Concepto +''', COUNT(*) AS Contador FROM ( ' + @Select + @Select1 
Set @CConceptos2	= @CDetalle2  
Set @CConceptos4	= @CDetalle4
Set @CConceptos3	= @CDetalle3 + @GroupBy + @GroupBy1 + ')' + @Concepto + ' GROUP BY Cartera, Fecha, Nivel1, Nivel2, reporte, Identificador '

Print 	'CONTANDO PRESTAMOS'
Print  	@CConceptos1 
Print 	@CDetalle2
Print 	@CConceptos2 
Print 	@CConceptos4
Print 	@CConceptos3

Print '@CConceptos1 = ' + Cast(Len(@CConceptos1) as Varchar(100))
Print '@CConceptos2 = ' + Cast(Len(@CConceptos2) as Varchar(100))
Print '@CConceptos3 = ' + Cast(Len(@CConceptos3) as Varchar(100))
Print '@CConceptos4 = ' + Cast(Len(@CConceptos4) as Varchar(100))

Print '-----------------------------------------'
Print 'HORA OBSERVACION 1 : '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'

Exec    (@CConceptos1 + @CDetalle1 + @CConceptos2 + @CConceptos4 + @CConceptos3)

If @Dato = 3 -- SOLO PRUEBAS
Begin
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRptSituacionCarteraContador]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin drop table [dbo].[tRptSituacionCarteraContador] End 
	
	CREATE TABLE [dbo].[tRptSituacionCarteraContador] (
		[Cartera]		[varchar] (500)		COLLATE Modern_Spanish_CI_AI NULL ,
		[Fecha]			[smalldatetime] NULL ,
		[Nivel1]		[varchar] (1031)	COLLATE Modern_Spanish_CI_AI NULL ,
		[Nivel2]		[varchar] (1031)	COLLATE Modern_Spanish_CI_AI NULL ,
		[Reporte]		[varchar] (5)		COLLATE Modern_Spanish_CI_AI NULL ,
		[Identificador] [varchar] (10)		COLLATE Modern_Spanish_CI_AI NULL ,
		[Concepto]		[varchar] (100)		COLLATE Modern_Spanish_CI_AI NULL ,
		[Contador]		[int] NULL 
	) ON [PRIMARY]
	INSERT INTO  tRptSituacionCarteraContador Select * From  #tRptSituacionCarteraContador 
End
 
CREATE TABLE #tRptSituacionCartera (
	[Cartera]		[varchar] (500)		COLLATE Modern_Spanish_CI_AI NULL ,
	[Ubicacion]		[varchar] (500)		COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha]			[smalldatetime]		NULL ,
	[Nivel1]		[varchar] (1031)	COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel2]		[varchar] (1031)	COLLATE Modern_Spanish_CI_AI NULL ,
	[Desembolso]	[decimal](38, 4)	NULL ,
	[Saldo]			[decimal](38, 4)	NULL ,
	[Reporte]		[varchar] (5)		COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] [varchar] (10)		COLLATE Modern_Spanish_CI_AI NULL ,
	[Clientes]		[int]				NULL ,
	[Prestamos]		[int]				NULL ,
	[CampoReporte]	[varchar] (50)		COLLATE Modern_Spanish_CI_AI NULL ,
	[GrupoReporte]	[varchar] (400)		COLLATE Modern_Spanish_CI_AI NULL) 

Set @Cadena 	= 'INSERT INTO #tRptSituacionCartera SELECT Principal.Cartera, Principal.Ubicacion, Principal.Fecha, Principal.Nivel1, Principal.Nivel2, '
Set @Cadena 	= @Cadena + 'Principal.Desembolso, Principal.Saldo, Principal.Reporte, Principal.Identificador, Clientes.Contador, Prestamos.Contador, '
Set @Cadena 	= @Cadena + 'Principal.CampoReporte, Principal.GrupoReporte FROM( '
---EN ESTA PARTE VA LA CADENA DE CONSULTA PRINCIPAL
Set @Cadena1 	= ' )Principal INNER JOIN (Select * From #tRptSituacionCarteraContador Where Concepto = ''CodUsuario'')Clientes ON Principal.Cartera '
Set @Cadena1 	= @Cadena1 + 'COLLATE Modern_Spanish_CI_AI = Clientes.Cartera AND Principal.Fecha = Clientes.Fecha AND Principal.Nivel2 COLLATE '
Set @Cadena1 	= @Cadena1 + 'Modern_Spanish_CI_AI = Clientes.Nivel2 AND Principal.Nivel1 COLLATE Modern_Spanish_CI_AI = Clientes.Nivel1 AND '
Set @Cadena1 	= @Cadena1 + 'Principal.Identificador = Clientes.Identificador AND Principal.Reporte COLLATE Modern_Spanish_CI_AI = Clientes.Reporte INNER '
Set @Cadena1 	= @Cadena1 + 'JOIN '
Set @Cadena2	= '(Select * From #tRptSituacionCarteraContador Where Concepto = ''CodPrestamo'')Prestamos ON Principal.Cartera COLLATE Modern_Spanish_CI_AI '
Set @Cadena2 	= @Cadena2 + '= Prestamos.Cartera AND Principal.Fecha = Prestamos.Fecha AND Principal.Nivel2 COLLATE Modern_Spanish_CI_AI = Prestamos.Nivel2 '
Set @Cadena2 	= @Cadena2 + 'AND Principal.Nivel1 COLLATE Modern_Spanish_CI_AI = Prestamos.Nivel1 AND Principal.Identificador = Prestamos.Identificador AND '
Set @Cadena2 	= @Cadena2 + 'Principal.Reporte COLLATE Modern_Spanish_CI_AI = Prestamos.Reporte '

Print '-----------------------------------------'
Print 'HORA OBSERVACION 2: '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'

Print @Cadena 
Print @CPrincipal1
Print @CDetalle1
Print @CPrincipal2
Print @CPrincipal4
Print @CPrincipal3
Print @Cadena1
Print @Cadena2  

Print '@Cadena 			= ' + Cast(Len(@Cadena) 	as Varchar(100))
Print '@CPrincipal1 	= ' + Cast(Len(@CPrincipal1) 	as Varchar(100))
Print '@CDetalle1 		= ' + Cast(Len(@CDetalle1) 	as Varchar(100))
Print '@CPrincipal2 	= ' + Cast(Len(@CPrincipal2) 	as Varchar(100))
Print '@CPrincipal4 	= ' + Cast(Len(@CPrincipal4) 	as Varchar(100))
Print '@CPrincipal3 	= ' + Cast(Len(@CPrincipal3) 	as Varchar(100))
Print '@Cadena1 		= ' + Cast(Len(@Cadena1) 	as Varchar(100))
Print '@Cadena2 		= ' + Cast(Len(@Cadena2) 	as Varchar(100))

Exec (@Cadena + @CPrincipal1 + @CDetalle1 + @CPrincipal2 + @CPrincipal4 + @CPrincipal3  + @Cadena1 + @Cadena2)

Set @Campo 	= ''
Set @Sumatoria	= ''

Print '-----------------------------------------'
Print 'HORA OBSERVACION 3: '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'


Declare curIdentificador Cursor For 
	SELECT     Identificador, Descripcion, DescIdentificador
	FROM         tCsPrReportesAnexos
	WHERE     (Reporte = @Reporte)
Open curIdentificador
Fetch Next From curIdentificador Into @Identificador, @ICampo, @IGrupo
While @@Fetch_Status = 0
Begin 	
	Set @Campo 	= @Campo + 'CASE WHEN identificador = '''+ @Identificador +''' THEN Desembolso ELSE 0 END AS '+ @Identificador +'Desemboslo, '
	Set @Campo 	= @Campo + 'CASE WHEN identificador = '''+ @Identificador +''' THEN Saldo ELSE 0 END AS '+ @Identificador +'Saldo, '
	Set @Campo 	= @Campo + 'CASE WHEN identificador = '''+ @Identificador +''' THEN Clientes ELSE 0 END AS '+ @Identificador +'Clientes, '
	Set @Campo 	= @Campo + 'CASE WHEN identificador = '''+ @Identificador +''' THEN Prestamos ELSE 0 END AS '+ @Identificador +'Prestamos, '
	Set @Campo 	= @Campo + 'CASE WHEN identificador = '''+ @Identificador +''' THEN CampoReporte ELSE NULL END AS '+ @Identificador +'Campo, '
	Set @Campo 	= @Campo + 'CASE WHEN identificador = '''+ @Identificador +''' THEN GrupoReporte ELSE NULL END AS '+ @Identificador +'Grupo, '

	Set @Sumatoria	= @Sumatoria + 'SUM('+ @Identificador +'Desemboslo) AS '+ @Identificador +'Desembolso, '
	Set @Sumatoria	= @Sumatoria + 'SUM('+ @Identificador +'Saldo) AS '+ @Identificador +'Saldo, '
	Set @Sumatoria	= @Sumatoria + 'SUM('+ @Identificador +'Clientes) AS '+ @Identificador +'Clientes, '
	Set @Sumatoria	= @Sumatoria + 'SUM('+ @Identificador +'Prestamos) AS '+ @Identificador +'Prestamos, '
	Set @Sumatoria	= @Sumatoria + 'ISNULL(Max('+ @Identificador +'Campo), '''+ @ICampo+''') AS '+ @Identificador +'Campo, '
	Set @Sumatoria	= @Sumatoria + 'ISNULL(Max('+ @Identificador +'Grupo), '''+ @IGrupo+''') AS '+ @Identificador +'Grupo, '
Fetch Next From curIdentificador Into  @Identificador, @ICampo, @IGrupo
End 
Close 		curIdentificador
Deallocate 	curIdentificador

Set @Campo 		= Substring(Ltrim(Rtrim(@Campo)), 1, Len(Ltrim(Rtrim(@Campo))) - 1) + ' '
Set @Sumatoria 	= Substring(Ltrim(Rtrim(@Sumatoria)), 1, Len(Ltrim(Rtrim(@Sumatoria))) - 1) + ' '

Print '-----------------------------------------'
Print 'HORA OBSERVACION 4: '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'


--Select * From #tRptSituacionCartera

If @Reporte = 'AH01'
Begin 
	SELECT     @Nivel1 = Ahorro
	FROM         tCsPrNivel
	WHERE     (Nivel = @Nivel1)

	SELECT     @Nivel2 = Ahorro
	FROM         tCsPrNivel
	WHERE     (Nivel = @Nivel2)
End 

If @Reporte in ('CA01', 'CA99')
Begin 
	SELECT     @Nivel1 = Cartera
	FROM         tCsPrNivel
	WHERE     (Nivel = @Nivel1)

	SELECT     @Nivel2 = Cartera
	FROM         tCsPrNivel
	WHERE     (Nivel = @Nivel2)
End 
Set @AvanceV 		= ''

If Left(@Reporte, 2) 	= 'CA' And (Select dbo.fduFechaATexto(FechaConsolidacion, 'AAAAMMDD') From vCsFechaConsolidacion) = dbo.fduFechaATexto(@Fecha, 'AAAAMMDD')
Begin
	IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[tCsAnalisisCtaOrdenNuevo]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin 
		Create Table #A (AvanceP Varchar(100))
		
		Set @Cadena = 'Insert Into #A SELECT LTRIM(RTRIM(STR(ROUND(Hecho.Hecho / CAST(Case Programado.Programado When 0 Then 1 Else Programado.Programado End AS decimal(18, 4)) * 100, 2), 6, 2))) + ''%'' AS Avance '
		Set @Cadena  = @Cadena + 'FROM (SELECT COUNT(*) AS Hecho FROM (SELECT DISTINCT tCsAnalisisCtaOrdenDetalle.CodPrestamo '
		Set @Cadena  = @Cadena + 'FROM tCsAnalisisCtaOrdenNuevo tCsAnalisisCtaOrdenDetalle with(nolock) INNER JOIN '
		Set @Cadena  = @Cadena + 'tCsPadronCarteraDet with(nolock) ON tCsAnalisisCtaOrdenDetalle.CodPrestamo = tCsPadronCarteraDet.CodPrestamo '
		Set @Cadena  = @Cadena + 'WHERE codoficina IN ('+ @CUbicacion +')) Datos) Hecho CROSS JOIN '
		Set @Cadena  = @Cadena + '(SELECT COUNT(*) AS Programado FROM (SELECT DISTINCT CodPrestamo '
		Set @Cadena  = @Cadena + 'FROM tCsCartera with(nolock) WHERE (Fecha IN (SELECT fechaconsolidacion '
		Set @Cadena  = @Cadena + 'FROM vcsfechaconsolidacion)) AND (Cartera = ''ACTIVA'') AND (Estado = ''VENCIDO'') AND codoficina IN ('+ @CUbicacion +')) Datos) Programado'
		Print @Cadena
		Exec (@Cadena)
		Select @AvanceV = AvanceP From #A
		If @AvanceV = '100.00%' Begin Set @AvanceV = '' End
		If @AvanceV = '0.00%' 	
		Begin 
			Set @Cadena = 'Insert Into #A SELECT LTRIM(RTRIM(STR(ROUND(Cast(Programado.Programado AS decimal(18, 4)), 2), 6, 2))) + ''%'' AS Avance '
			Set @Cadena  = @Cadena + 'FROM (SELECT COUNT(*) AS Hecho FROM (SELECT DISTINCT tCsAnalisisCtaOrdenDetalle.CodPrestamo '
			Set @Cadena  = @Cadena + 'FROM tCsAnalisisCtaOrdenNuevo tCsAnalisisCtaOrdenDetalle with(nolock) INNER JOIN '
			Set @Cadena  = @Cadena + 'tCsPadronCarteraDet with(nolock) ON tCsAnalisisCtaOrdenDetalle.CodPrestamo = tCsPadronCarteraDet.CodPrestamo '
	        		Set @Cadena  = @Cadena + 'WHERE codoficina IN ('+ @CUbicacion +')) Datos) Hecho CROSS JOIN '
			Set @Cadena  = @Cadena + '(SELECT COUNT(*) AS Programado FROM (SELECT DISTINCT CodPrestamo '
			Set @Cadena  = @Cadena + 'FROM tCsCartera with(nolock) WHERE (Fecha IN (SELECT fechaconsolidacion '
			Set @Cadena  = @Cadena + 'FROM vcsfechaconsolidacion)) AND (Cartera = ''ACTIVA'') AND (Estado = ''VENCIDO'') AND codoficina IN ('+ @CUbicacion +')) Datos) Programado'
			Select @AvanceV = AvanceP From #A
			If @AvanceV = '0.00%' 
			Begin 
				Set @AvanceV = '' 
			End
			Else
			Begin
				Set @AvanceV = '0.01%'
			End
		End
		Drop Table #A
	End
End

Set @Cadena 	= 'SELECT UBI = '''+ @UBI +''', TSA = '''+ @TSA +''',  ClaseCartera = '''+ @CCA +''',  CN1 = '''+ @Nivel1 +''', CN2 = '''+ @Nivel2 +''',  '
Set @Cadena 	= @Cadena + 'ID = '''+ @ID +''', Titulo = '''+ @OtroDato +''', TipoSaldo = '''+ @TipoSaldo +''', Cartera = ''' + @AvanceV + ''' + Rtrim(Ltrim(Cartera)) '
Set @Cadena 	= @Cadena + ', Ubicacion, Fecha, '
Set @Cadena 	= @Cadena + 'Nivel1, Nivel2, Reporte,  2 As Resumen, ' + @Sumatoria 
Set @Cadena1 	= 'FROM (SELECT Cartera, Ubicacion, Fecha, Nivel1, Nivel2, Reporte, ' + @Campo  
Set @Cadena1 	= @Cadena1 + 'FROM #tRptSituacionCartera) Datos '
Set @Cadena1 	= @Cadena1 + 'GROUP BY Cartera, Ubicacion, Fecha, Reporte, Nivel1, Nivel2'

Print @Cadena + @Cadena1

Exec (@Cadena + @Cadena1)

Drop Table #tRptSituacionCartera
Drop Table #tRptSituacionCarteraContador
Print '-----------------------------------------'
Print 'HORA FIN: '  + Cast(datepart(minute, getdate()) as Varchar(100)) + ':'  + Cast(datepart(second, getdate()) as Varchar(100))
Print '-----------------------------------------'
GO