SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsPrRegulatorios1]
@Fecha 		SmallDateTime,
@Regulatorio		Varchar(10)
As

Declare @Reporte 	Varchar(100)
Declare @CodFila		Varchar(3)
Declare @Identificador		Varchar(15)
Declare	@Agrupado		Varchar(5)
Declare @MostrarCuenta		Varchar(100)
Declare @Formula		Varchar(1000)
Declare @Procedimiento		Varchar(100)
Declare @Parametros		Varchar(100)
Declare @Redondeo		Int
Declare @PeriodoAnterior	Int
Declare @TempFec 		SmallDateTime

Declare @Parametro		Varchar(100)

Set @Reporte 		= @Regulatorio
----

Declare @Servidor	Varchar(50)
Declare @BaseDatos	Varchar(50)
Declare @Cadena		Varchar(4000)
Declare @Tabla		Varchar(50)
Declare @Temporal	Varchar(4000)

SELECT     @Servidor = Servidor, @BaseDatos = BaseDatos
FROM         tClOficinas
WHERE     (CodOficina = '99')

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[B]End
Set @Cadena = 'CREATE TABLE [dbo].[B] ( '
Set @Cadena = @Cadena + '[Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL ' 
Set @Cadena = @Cadena + ') ON [PRIMARY] '
Exec(@Cadena)
Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@Servidor))
Insert Into B
Exec master..xp_cmdshell @Cadena

SELECT   @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1))) 
FROM         B
WHERE     (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')

Print @Servidor	
Set @Servidor = '[' + @Servidor + '].'	


CREATE TABLE #AQQQQQ (
	[Reporte] 		[varchar] (10) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodFila] 		[varchar] (3) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Descripcion] 		[varchar] (400) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] 	[varchar] (15) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[DescIdentificador] 	[varchar] (400) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Agrupado] 		[varchar] (5) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Nivel]	 		[int] 		NULL ,
	[Comentario] 		[varchar] (3) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[DetComentario] 	[varchar] (400) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Cuenta] 		[varchar] (25) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[MostrarCuenta] 	[varchar] (100) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[pInicio] 		[int] 		NULL ,
	[PFin] 			[int] 		NULL ,
	[Formula]		[varchar] (1000)	COLLATE Modern_Spanish_CI_AI NULL,
	[Procedimiento]		[varchar] (100) 	COLLATE Modern_Spanish_CI_AI NULL,
	[Parametros]		[varchar] (100)  	COLLATE Modern_Spanish_CI_AI NULL,
	[Valor]			[decimal](18,4) 	NULL, 
	[Redondeo] 		[int] 		NULL,
	[Signo]			[Varchar] (1) 	COLLATE Modern_Spanish_CI_AI NULL	,
	[OtroDato]		[varchar] (1000)	COLLATE Modern_Spanish_CI_AI NULL	,
	[PeriodoAnterior]	[Int] 		NULL					,
	[Columna] 		[varchar] (500) 	COLLATE Modern_Spanish_CI_AI NULL	,
	[Generado]		[DateTime] 	NULL
) 

CREATE TABLE #AQQQQQ2 (
	[Reporte] 		[varchar] 	(10) 	COLLATE Modern_Spanish_CI_AI  NULL 	,
	[CodFila] 		[varchar] 	(3) 	COLLATE Modern_Spanish_CI_AI  NULL 	,
	[Identificador] 	[varchar] 	(15) 	COLLATE Modern_Spanish_CI_AI NULL 		,
	[Agrupado] 		[varchar] 	(5) 	COLLATE Modern_Spanish_CI_AI  NULL 	,
	[Valor]			[decimal]	(18,4) 	NULL)
----

Declare curIdentificador1 Cursor For 
	SELECT     Reporte, CodFila, Identificador, Agrupado, ISNULL(MostrarCuenta, 'X') AS MostrarCuenta, RTRIM(LTRIM(ISNULL(Formula, ''))) AS Formula, 
	           RTRIM(LTRIM(ISNULL(Procedimiento, ''))) AS Procedimiento, Redondeo, RTRIM(LTRIM(ISNULL(Parametros, ''))) AS Parametros, 
		   PeriodoAnterior = Isnull(PeriodoAnterior, 0)
	FROM         tCsPrReportesAnexos
	WHERE     (Reporte = @Reporte)  
	Order By Nivel Desc
Open curIdentificador1
Fetch Next From curIdentificador1 Into 	@Reporte, 	@CodFila, 		@Identificador,	@Agrupado, 	@MostrarCuenta, 
					@Formula,	@Procedimiento, 	@Redondeo,	@Parametros,	@PeriodoAnterior 	
While @@Fetch_Status = 0
Begin	
	If @PeriodoAnterior > 0 
	Begin
		Set @TempFec = cast(dbo.FdufechaAtexto(DateAdd(Month, 1, DateAdd(Month, -1* @PeriodoAnterior, @Fecha)) , 'AAAAMM') + '01' as SmallDateTime) - 1
	End
	Else
	Begin
		Set @TempFec =  @Fecha
	End
	
	Print 'Fecha del Dato	: ' + IsNull(Cast(@TempFec as Varchar(100))	, 'Nulo')
	Print 'Identificador	: ' + @Identificador

	If @Formula = '' And @Procedimiento = ''
	Begin
		Print 'INGRESO CUENTA CONTABLE'
		If @MostrarCuenta <> 'X'
		Begin
			Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable ''' + dbo.fduFechaATexto(@TempFec,  'AAAAMMDD') + ''', '''+ @MostrarCuenta +''', ''CodOficina'''
			Exec(@Cadena)
			Print @Cadena
			
			Set @Cadena = 'INSERT INTO #AQQQQQ2 (Reporte, CodFila, Identificador, Agrupado, Valor) '
			Set @Cadena = @Cadena + 'SELECT '''+ @Reporte +''' AS Reporte, '''+ @CodFila +''' AS CodFila, ''X'' + dbo.fduRellena(''0'', KRptID_Tabla.Agrupado, 2, ''D'') + ''.'' + ''' + @Identificador + ''' AS Identificador, '''+ @Agrupado +''' AS Agrupado, ISNULL(SUM(KRptID_Tabla.Saldo), 0) AS Valor '
			Set @Cadena = @Cadena + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
			Set @Cadena = @Cadena + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
			Set @Cadena = @Cadena + 'WHERE (Parametro = '''+ @MostrarCuenta +''') AND (Fecha = ''' + dbo.fduFechaATexto(@TempFec, 'AAAAMMDD') + ''') '
			Set @Cadena = @Cadena + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
			Set @Cadena = @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
			Set @Cadena = @Cadena + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro, KRptID_Tabla.Agrupado '				
		End
		Else
		Begin
			Set @Cadena = 'INSERT INTO #AQQQQQ2 (Reporte, CodFila, Identificador, Agrupado, Valor) ' 
			Set @Cadena = 'VALUES ('''+ @Reporte + ''', '''+ @CodFila + ''',''X.'' + '''+ @Identificador + ''', '''+ @Agrupado + ''', 0)'
		End
		
		Print @Cadena
		Exec (@Cadena)
		
		Insert Into #AQQQQQ (	Reporte, CodFila, Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, 
					DetComentario, Cuenta, MostrarCuenta, pInicio, PFin, Formula, Procedimiento, Redondeo, Signo,
					Parametros, OtroDato, PeriodoAnterior, Generado, Columna, Valor)
		SELECT     QQQQ.Reporte, QQQQ.CodFila, tCsPrReportesAnexos.Descripcion, QQQQ.Identificador, tCsPrReportesAnexos.DescIdentificador, QQQQ.Agrupado, 
	                      	      tCsPrReportesAnexos.Nivel, tCsPrReportesAnexos.Comentario, tCsPrReportesAnexos.DetComentario, tCsPrReportesAnexos.Cuenta, 
		                      tCsPrReportesAnexos.MostrarCuenta, tCsPrReportesAnexos.pInicio, tCsPrReportesAnexos.PFin, tCsPrReportesAnexos.Formula, tCsPrReportesAnexos.Procedimiento, 
		                      tCsPrReportesAnexos.Redondeo, tCsPrReportesAnexos.Signo, tCsPrReportesAnexos.Parametros, tCsPrReportesAnexos.OtroDato, 
		                      ISNULL(tCsPrReportesAnexos.PeriodoAnterior, 0) AS PeriodoAnterior, GETDATE() AS Generado, tCsPrReportesAnexos.Columna, QQQQ.Valor
		FROM         tCsPrReportesAnexos INNER JOIN
		                    #AQQQQQ2 QQQQ ON tCsPrReportesAnexos.Reporte = QQQQ.Reporte AND tCsPrReportesAnexos.CodFila = QQQQ.CodFila AND 
		                      tCsPrReportesAnexos.Agrupado = QQQQ.Agrupado
		WHERE     (tCsPrReportesAnexos.Reporte = @Reporte) AND (tCsPrReportesAnexos.CodFila = @CodFila) AND (tCsPrReportesAnexos.Identificador = @Identificador) AND 
		          (tCsPrReportesAnexos.Agrupado = @Agrupado)
	
		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 								= @Reporte 		And  
					CodFila									= @CodFila		And
					SUBSTRING(Identificador, CHARINDEX('.', Identificador, 1) + 1, 100)	= @Identificador	And 
					Agrupado								= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where 			Reporte 								= @Reporte 		And  
					CodFila									= @CodFila		And
					SUBSTRING(Identificador, CHARINDEX('.', Identificador, 1) + 1, 100)	= @Identificador	And 
					Agrupado								= @Agrupado 

		Truncate Table #AQQQQQ2 
	End 
	
	If @Formula = 'AGRUPAR'
	Begin
		Print 'INGRESO A AGRUPAR'
		Set @Cadena = 'INSERT INTO #AQQQQQ2 (Reporte, CodFila, Identificador, Agrupado, Valor) '
		Set @Cadena = @Cadena + 'SELECT '''+ @Reporte +''' AS Reporte, '''+ @CodFila +''' AS Codfila, SUBSTRING(Identificador, 1, CHARINDEX(''.'', Identificador, 1)) + '''+ @Identificador +''' AS Identificador, '''+ @Agrupado +''' AS Agrupado, SUM(Valor) AS Valor '
		Set @Cadena = @Cadena + 'FROM #AQQQQQ '
		Set @Cadena = @Cadena + 'WHERE (Identificador LIKE SUBSTRING(Identificador, 1, CHARINDEX(''.'', Identificador, 1)) + '''+ @Identificador  + '._'') AND (CodFila <> '''+ @CodFila +''') '
		Set @Cadena = @Cadena + 'GROUP BY SUBSTRING(Identificador, 1, CHARINDEX(''.'', Identificador, 1)) + '''+ @Identificador +''''

		Print @Cadena
		Exec (@Cadena)

		Insert Into #AQQQQQ (	Reporte, CodFila, Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, 
					DetComentario, Cuenta, MostrarCuenta, pInicio, PFin, Formula, Procedimiento, Redondeo, Signo,
					Parametros, OtroDato, PeriodoAnterior, Generado, Columna, Valor)
		SELECT     QQQQ.Reporte, QQQQ.Codfila, tCsPrReportesAnexos.Descripcion, QQQQ.Identificador, tCsPrReportesAnexos.DescIdentificador, QQQQ.Agrupado, 
		                      tCsPrReportesAnexos.Nivel, tCsPrReportesAnexos.Comentario, tCsPrReportesAnexos.DetComentario, tCsPrReportesAnexos.Cuenta, 
		                      tCsPrReportesAnexos.MostrarCuenta, tCsPrReportesAnexos.pInicio, tCsPrReportesAnexos.PFin, tCsPrReportesAnexos.Formula, tCsPrReportesAnexos.Procedimiento, 
		                      tCsPrReportesAnexos.Redondeo, tCsPrReportesAnexos.Signo, tCsPrReportesAnexos.Parametros, tCsPrReportesAnexos.OtroDato, 
		                      ISNULL(tCsPrReportesAnexos.PeriodoAnterior, 0) AS PeriodoAnterior, GETDATE() AS Generado, tCsPrReportesAnexos.Columna, QQQQ.Valor
		FROM      #AQQQQQ2 QQQQ INNER JOIN
		                      tCsPrReportesAnexos ON QQQQ.Reporte = tCsPrReportesAnexos.Reporte AND QQQQ.Agrupado = tCsPrReportesAnexos.Agrupado AND 
		                      QQQQ.Codfila = tCsPrReportesAnexos.CodFila
		WHERE     (tCsPrReportesAnexos.Reporte = @Reporte) AND (tCsPrReportesAnexos.CodFila = @CodFila) AND (tCsPrReportesAnexos.Identificador = @Identificador) AND 
		          (tCsPrReportesAnexos.Agrupado = @Agrupado)
	
		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 								= @Reporte 		And  
					CodFila									= @CodFila		And
					SUBSTRING(Identificador, CHARINDEX('.', Identificador, 1) + 1, 100)	= @Identificador	And 
					Agrupado								= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where 			Reporte 								= @Reporte 		And  
					CodFila									= @CodFila		And
					SUBSTRING(Identificador, CHARINDEX('.', Identificador, 1) + 1, 100)	= @Identificador	And 
					Agrupado								= @Agrupado
		
		Truncate Table #AQQQQQ2 
		Set @Formula = '' 		
	End
	
	If @Procedimiento = 'pCsCaAnexosSaldo'
	Begin	
		-- 02 0 89 2 1 TODAS DD
		Set @Parametros = Replace(@Parametros, 'DD', 'DDO')
		Set @Parametro	= Replace(Replace(Replace(Replace(@Parametros, ',', ''), '''', ''), ' ', ''), ' ', '')
		Set @Cadena = 'Declare @Saldo Decimal(18,4) ' + Char(13)
		Set @Cadena = @Cadena + 'Exec '+ @Procedimiento +' ''' + dbo.fduFechaATexto(@TempFec, 'AAAAMMDD') + ''''+ @Parametros +', @Saldo Out ' + Char(13)
		
		Print @Cadena
		Exec (@Cadena)
		
		Set @Cadena = 'INSERT INTO #AQQQQQ2 (Reporte, CodFila, Identificador, Agrupado, Valor) '
		Set @Cadena = @Cadena + 'SELECT '''+ @Reporte +''' AS Reporte, '''+ @CodFila +''' AS CodFila, ''X'' + dbo.fduRellena(''0'', KRptID_Tabla.Agrupado, 2, ''D'') + ''.'' + ''' + @Identificador + ''' AS Identificador, '''+ @Agrupado +''' AS Agrupado, ISNULL(SUM(KRptID_Tabla.Saldo), 0) AS Valor '
		Set @Cadena = @Cadena + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
		Set @Cadena = @Cadena + 'FROM dbo.KRptID_Tabla KRptID_Tabla '
		Set @Cadena = @Cadena + 'WHERE (Parametro = '''+ @Parametro +''') AND (Fecha = ''' + dbo.fduFechaATexto(@TempFec, 'AAAAMMDD') + ''') '
		Set @Cadena = @Cadena + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
		Set @Cadena = @Cadena + 'dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
		Set @Cadena = @Cadena + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro, KRptID_Tabla.Agrupado '				
		
		Print @Cadena
		Exec (@Cadena)

		Insert Into #AQQQQQ (	Reporte, CodFila, Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, 
					DetComentario, Cuenta, MostrarCuenta, pInicio, PFin, Formula, Procedimiento, Redondeo, Signo,
					Parametros, OtroDato, PeriodoAnterior, Generado, Columna, Valor)
		SELECT     QQQQ.Reporte, QQQQ.CodFila, tCsPrReportesAnexos.Descripcion, QQQQ.Identificador, tCsPrReportesAnexos.DescIdentificador, QQQQ.Agrupado, 
	                      	      tCsPrReportesAnexos.Nivel, tCsPrReportesAnexos.Comentario, tCsPrReportesAnexos.DetComentario, tCsPrReportesAnexos.Cuenta, 
		                      tCsPrReportesAnexos.MostrarCuenta, tCsPrReportesAnexos.pInicio, tCsPrReportesAnexos.PFin, tCsPrReportesAnexos.Formula, tCsPrReportesAnexos.Procedimiento, 
		                      tCsPrReportesAnexos.Redondeo, tCsPrReportesAnexos.Signo, tCsPrReportesAnexos.Parametros, tCsPrReportesAnexos.OtroDato, 
		                      ISNULL(tCsPrReportesAnexos.PeriodoAnterior, 0) AS PeriodoAnterior, GETDATE() AS Generado, tCsPrReportesAnexos.Columna, QQQQ.Valor
		FROM         tCsPrReportesAnexos INNER JOIN
		                    #AQQQQQ2 QQQQ ON tCsPrReportesAnexos.Reporte = QQQQ.Reporte AND tCsPrReportesAnexos.CodFila = QQQQ.CodFila AND 
		                      tCsPrReportesAnexos.Agrupado = QQQQ.Agrupado
		WHERE     (tCsPrReportesAnexos.Reporte = @Reporte) AND (tCsPrReportesAnexos.CodFila = @CodFila) AND (tCsPrReportesAnexos.Identificador = @Identificador) AND 
		          (tCsPrReportesAnexos.Agrupado = @Agrupado)
	
		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 								= @Reporte 		And  
					CodFila									= @CodFila		And
					SUBSTRING(Identificador, CHARINDEX('.', Identificador, 1) + 1, 100)	= @Identificador	And 
					Agrupado								= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where 			Reporte 								= @Reporte 		And  
					CodFila									= @CodFila		And
					SUBSTRING(Identificador, CHARINDEX('.', Identificador, 1) + 1, 100)	= @Identificador	And 
					Agrupado								= @Agrupado 

		Truncate Table #AQQQQQ2 
	End	
Fetch Next From curIdentificador1 Into 	@Reporte, 	@CodFila, 		@Identificador,	@Agrupado, 	@MostrarCuenta, 
					@Formula,	@Procedimiento, 	@Redondeo,	@Parametros,	@PeriodoAnterior 	
End 
Close 		curIdentificador1
Deallocate 	curIdentificador1


Update #AQQQQQ
Set 	Valor 		= 0,
	Generado 	= GetDate()
Where Valor Is null

Delete From tCsPrRegulatorios where Reporte = @Regulatorio and Fecha = @Fecha
Insert Into tCsPrRegulatorios
Select 	Fecha = @Fecha, Reporte, dbo.fduRellena(' ', '', (Substring(DescIdentificador, 4, 1)-1)* 2, 'D') + Descripcion as Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, DetComentario, 
	Round(Abs(Sum(Valor * Cast((Signo + '1') as int))), Redondeo) as Saldo , OtroDato, Columna, Max(Generado) as Generacion
From #AQQQQQ	
Group by Reporte, Descripcion, DescIdentificador, Identificador, Agrupado, Nivel, Comentario, DetComentario, Redondeo, OtroDato, Columna
Order BY Agrupado

DROP TABLE #AQQQQQ
DROP TABLE #AQQQQQ2
GO