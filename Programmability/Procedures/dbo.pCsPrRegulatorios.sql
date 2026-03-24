SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- DROP Procedure pCsPrRegulatorios
-- Exec pCsPrRegulatorios '20110531', 'REDECAR'

CREATE Procedure [dbo].[pCsPrRegulatorios]
@Fecha 			SmallDateTime,
@Regulatorio	Varchar(10)
As
--Set @Fecha = '20080831'
declare @T1 datetime
declare @T2 datetime

declare @Y1 datetime
declare @Y2 datetime

Declare @Servidor	Varchar(50)
Declare @BaseDatos	Varchar(50)
Declare @Cadena		Varchar(4000)
Declare @Tabla		Varchar(50)
Declare @Temporal	Varchar(4000)
Declare @Contador	Int 

SELECT     @Contador = Count(*)
FROM         tCsServidores
WHERE     (IdTextual = CAST(YEAR(@Fecha) as Varchar(10))) AND (Tipo = 2)

If @Contador Is Null Begin Set @Contador = 0 End

If @Contador = 1
Begin 
	SELECT     @Servidor = NombreIP, @BaseDatos = NombreBD
	FROM         tCsServidores
	WHERE     (IdTextual = CAST(YEAR(@Fecha) as Varchar(10))) AND (Tipo = 2)
End
Else
Begin
	SELECT     @Servidor = Servidor, @BaseDatos = BaseDatos
	FROM         tClOficinas
	WHERE     (CodOficina = '99')
End


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
	[Reporte] 			[varchar] (10) 		COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodFila] 			[varchar] (3) 		COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Descripcion] 		[varchar] (400) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] 	[varchar] (15) 		COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[DescIdentificador] [varchar] (400) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Agrupado] 			[varchar] (5) 		COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Nivel]	 			[int] 				NULL ,
	[Comentario] 		[varchar] (3) 		COLLATE Modern_Spanish_CI_AI NULL ,
	[DetComentario] 	[varchar] (400) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Cuenta] 			[varchar] (25) 		COLLATE Modern_Spanish_CI_AI NULL ,
	[MostrarCuenta] 	[varchar] (100) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[pInicio] 			[int] 				NULL ,
	[PFin] 				[int] 				NULL ,
	[Formula]			[varchar] (1000)	COLLATE Modern_Spanish_CI_AI NULL,
	[Procedimiento]		[varchar] (100) 	COLLATE Modern_Spanish_CI_AI NULL,
	[Parametros]		[varchar] (100)  	COLLATE Modern_Spanish_CI_AI NULL,
	[Valor]				[decimal] (18,4) 	NULL, 
	[Redondeo] 			[int] 				NULL,
	[Signo]				[Varchar] (1) 		COLLATE Modern_Spanish_CI_AI NULL	,
	[OtroDato]			[varchar] (1000)	COLLATE Modern_Spanish_CI_AI NULL	,
	[PeriodoAnterior]	[Int] 				NULL					,
	[Columna] 			[varchar] (500) 	COLLATE Modern_Spanish_CI_AI NULL	,
	[Generado]			[DateTime] 			NULL
) 

CREATE TABLE #AQQQQQ2 (
	[Reporte] 			[varchar] 	(10) 	COLLATE Modern_Spanish_CI_AI  NULL 	,
	[CodFila] 			[varchar] 	(3) 	COLLATE Modern_Spanish_CI_AI  NULL 	,
	[Identificador] 	[varchar] 	(15) 	COLLATE Modern_Spanish_CI_AI NULL 		,
	[Agrupado] 			[varchar] 	(5) 	COLLATE Modern_Spanish_CI_AI  NULL 	,
	[Valor]				[decimal]	(18,4) 	NULL)
 
Insert Into #AQQQQQ (Reporte, CodFila, Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, 
			DetComentario, Cuenta, MostrarCuenta, pInicio, PFin, Formula, Procedimiento, Redondeo, Signo,
			Parametros, OtroDato, PeriodoAnterior, Generado, Columna)
SELECT     Reporte, CodFila, Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, 
			DetComentario, Cuenta, MostrarCuenta, pInicio, PFin, Formula, Procedimiento, Redondeo, Signo,
			Parametros, OtroDato, Isnull(PeriodoAnterior,0) as PeriodoAnterior, GetDAte() as Generado, Columna
FROM         tCsPrReportesAnexos
WHERE     (Reporte = @Regulatorio)
ORDER BY Agrupado, CodFila

Declare @Reporte 		Varchar(10)
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

set @T1 = getdate()

Declare curIdentificador Cursor For 
	SELECT  Reporte, CodFila, Identificador, Agrupado, IsNull(MostrarCuenta, 'X') as MostrarCuenta, 
		RTrim(Ltrim(IsNull(Formula, ''))) as Formula, RTrim(Ltrim(IsNull(Procedimiento, ''))) as Procedimiento, 
		Redondeo, RTrim(Ltrim(IsNull(Parametros, ''))) as Parametros, PeriodoAnterior
	FROM    #AQQQQQ
	Order By Nivel Desc
Open curIdentificador
Fetch Next From curIdentificador Into 	@Reporte, 	@CodFila, 		@Identificador,	@Agrupado, 	@MostrarCuenta, 
					@Formula,	@Procedimiento, 	@Redondeo,	@Parametros,	@PeriodoAnterior 	
While @@Fetch_Status = 0
Begin 	
	
	Print 'Reporte			: ' + Isnull(@Reporte								, 'Nulo')
	Print 'CodFila			: ' + Isnull(@CodFila								, 'Nulo')
	Print 'Identificador	: ' + IsNull(@Identificador							, 'Nulo')
	Print 'Agrupado			: ' + IsNull(@Agrupado								, 'Nulo')
	Print 'MostrarCuenta	: ' + IsNull(@MostrarCuenta							, 'Nulo')
	Print 'Formula			: ' + IsNull(@Formula								, 'Nulo')
	Print 'Procedimiento	: ' + IsNull(@Procedimiento							, 'Nulo')
	Print 'Redondeo			: ' + IsNull(Cast(@Redondeo as Varchar(5))			, 'Nulo')
	Print 'Parametros		: ' + IsNull(@Parametros							, 'Nulo')		
	Print 'PeriodoAnterior	: ' + IsNull(Cast(@PeriodoAnterior as Varchar(5))	, 'Nulo')

	If @PeriodoAnterior > 0 
	Begin
		Set @TempFec = cast(dbo.FdufechaAtexto(DateAdd(Month, 1, DateAdd(Month, -1* @PeriodoAnterior, @Fecha)) , 'AAAAMM') + '01' as SmallDateTime) - 1
	End
	Else
	Begin
		Set @TempFec =  @Fecha
	End
	
	Print 'Fecha del Dato	: ' + IsNull(Cast(@TempFec as Varchar(100))	, 'Nulo')

	If @Formula = '' And @Procedimiento = ''
	Begin
		If @MostrarCuenta <> 'X'
		Begin
			Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable ''' + dbo.fduFechaATexto(@TempFec,  'AAAAMMDD') + ''', '''+ @MostrarCuenta +''''
			Exec(@Cadena)
			Print @Cadena
			
			Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) SELECT Isnull(SUM(KRptID_Tabla.Saldo), 0) AS Saldo '
			Set @Cadena = @Cadena + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
			Set @Cadena = @Cadena + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
			Set @Cadena = @Cadena + 'WHERE (Parametro = '''+ @MostrarCuenta +''') AND (Fecha = ''' + dbo.fduFechaATexto(@TempFec, 'AAAAMMDD') + ''') '
			Set @Cadena = @Cadena + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
			Set @Cadena = @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
			Set @Cadena = @Cadena + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro '
		End
		Else
		Begin
			Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) VALUES (0)'
		End
		
		Print @Cadena
		Exec (@Cadena)
		
		Update #AQQQQQ2
		Set 	Reporte 	= @Reporte, 
			CodFila		= @CodFila,
			Identificador	= @Identificador, 
			Agrupado	= @Agrupado
	
		Update #AQQQQQ
		Set 	Valor 		= #AQQQQQ2.Valor,
			Generado 	= GetDate()
		From #AQQQQQ Inner Join #AQQQQQ2 On 	#AQQQQQ.Reporte 	= #AQQQQQ2.Reporte 		And
							#AQQQQQ.CodFila 	= #AQQQQQ2.CodFila 		And
							#AQQQQQ.Identificador 	= #AQQQQQ2.Identificador 	And
							#AQQQQQ.Agrupado 	= #AQQQQQ2.Agrupado 	
	
		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 

		Truncate Table #AQQQQQ2 
	End 
	If @Formula = 'AGRUPAR'
	Begin
		Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) SELECT IsNull(Sum(Valor),0) as Saldo FROM #AQQQQQ WHERE (Identificador LIKE '''+ @Identificador +'._'') AND (CodFila <> '''+ @CodFila +''')'

		Print @Cadena
		Exec (@Cadena)
		
		Update #AQQQQQ2
		Set 	Reporte 	= @Reporte, 
			CodFila		= @CodFila,
			Identificador	= @Identificador, 
			Agrupado	= @Agrupado
	
		Update #AQQQQQ
		Set 	Valor 		= #AQQQQQ2.Valor,
			Generado 	= GetDate()
		From #AQQQQQ Inner Join #AQQQQQ2 On 	#AQQQQQ.Reporte 	= #AQQQQQ2.Reporte 		And
							#AQQQQQ.CodFila 	= #AQQQQQ2.CodFila 		And
							#AQQQQQ.Identificador 	= #AQQQQQ2.Identificador 	And
							#AQQQQQ.Agrupado 	= #AQQQQQ2.Agrupado 	
	
		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 

		Truncate Table #AQQQQQ2 
		Set @Formula = '' 		
	End
	If @Formula <> ''
	Begin		
		Declare @PI		Int
		Declare @PF		Int
		Declare @Var		Varchar(50)
		Declare @Var1		Decimal(18,4)
		
		Set @Formula 	= Ltrim(Rtrim(@Formula))
		Set @Formula 	= Replace(@Formula, ' ', '')
		Set @Temporal	= @Formula		
		
		Set @Formula 	= Replace(@Formula, '(', '$')
		Set @Formula 	= Replace(@Formula, ')', '$')
		Set @Formula 	= Replace(@Formula, '+', '$')
		Set @Formula 	= Replace(@Formula, '-', '$')
		Set @Formula 	= Replace(@Formula, '*', '$')
		Set @Formula 	= Replace(@Formula, '/', '$')
		If Left	(@Formula, 1) <> '$' Begin Set @Formula = '$' + @Formula End
		If Right(@Formula, 1) <> '$' Begin Set @Formula = @Formula + '$' End
		
		Set @Cadena = @Formula 

		While @Cadena <> ''
		Begin
			Set @PI = CharIndex('$', @Cadena, 1)
			If @PI <> 0 And @Cadena <> '$'
			Begin
				Set @PF 	= CharIndex('$', @Cadena, @PI + 1)
				Set @Var	= SubString(@Cadena, @PI + 1, @PF - 2)
				Set @Cadena	= SubString(@Cadena, @PF, 1000)
				Set @Var1	= 0.0001
				Select @Var1 	= Sum(Valor * Cast((Signo + '1') as int)) From #AQQQQQ
				Where Identificador = @Var
				If @Var1 <> 0.0001
				Begin
					--Print 'ENTRA'
					--Print @Temporal
					--Print @Var
					--Print @Var1
					Set @Temporal 	= Replace(@Temporal, @Var, 'XXX')
					
					Set @Temporal = Replace(@Temporal, '(XXX', '(YYY')
					Set @Temporal = Replace(@Temporal, ')XXX', ')YYY')
					Set @Temporal = Replace(@Temporal, '+XXX', '+YYY')
					Set @Temporal = Replace(@Temporal, '-XXX', '-YYY')
					Set @Temporal = Replace(@Temporal, '*XXX', '*YYY')
					Set @Temporal = Replace(@Temporal, '/XXX', '/YYY')
					
					Set @Temporal 	= Replace(@Temporal, 'YYY', '[' + Cast(Round(@Var1, 4) as Varchar(50)))
					Set @Temporal 	= Replace(@Temporal, 'XXX', @Var)
				End
				--Print '----------------'
				--Print @Temporal
				Print @Var
				Print @Var1
				Print @Formula 
			End 
			Else
			Begin
				Set @Cadena = ''
			End
		End
		Set @Temporal = Replace(@Temporal, '[', '')	
		Set @Temporal = Replace(@Temporal, '--', '+')	
		Print 'FINAL = ' + @Temporal
		Set @Cadena = 'INSERT INTO #AQQQQQ2 (Valor) Select ' + @Temporal + ' As Saldo'
		Print @Cadena
		Exec (@Cadena)

		Update #AQQQQQ2
		Set 	Reporte 	= @Reporte, 
			CodFila		= @CodFila,
			Identificador	= @Identificador, 
			Agrupado	= @Agrupado
	
		Update #AQQQQQ
		Set 	Valor 		= #AQQQQQ2.Valor,
			Generado 	= GetDate()
		From #AQQQQQ Inner Join #AQQQQQ2 On 	#AQQQQQ.Reporte 	= #AQQQQQ2.Reporte 		And
							#AQQQQQ.CodFila 	= #AQQQQQ2.CodFila 		And
							#AQQQQQ.Identificador 	= #AQQQQQ2.Identificador 	And
							#AQQQQQ.Agrupado 	= #AQQQQQ2.Agrupado 	
	
		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 


		Truncate Table #AQQQQQ2 
	End
	If @Procedimiento <> ''
	Begin	
		set @Y1 = getdate()

		Set @Cadena = 'Declare @Saldo Decimal(18,4) ' + Char(13)
		Set @Cadena = @Cadena + 'Exec '+ @Procedimiento +' ''' + dbo.fduFechaATexto(@TempFec, 'AAAAMMDD') + ''''+ @Parametros +', @Saldo Out ' + Char(13)
		Set @Cadena = @Cadena + 'INSERT INTO #AQQQQQ2 (Valor)  VALUES (@Saldo)'  + Char(13) + 'Print ''Valor Temporal Usado: '' + Cast(Isnull(@Saldo, 0) as Varchar(100))'
		Print @Cadena
		Exec (@Cadena)
		print 'CALCULO EL PROCEDIMIENTO'
		
		set @Y2 = getdate()
		print 'termino y '+ cast( datediff(millisecond, @Y1, @Y2) as varchar(8))

		Update #AQQQQQ2
		Set 	Reporte 	= @Reporte, 
			CodFila		= @CodFila,
			Identificador	= @Identificador, 
			Agrupado	= @Agrupado

		--Select * from #AQQQQQ2

		Update #AQQQQQ
		Set 	Valor 		= #AQQQQQ2.Valor,
			Generado 	= GetDate()
		From #AQQQQQ Inner Join #AQQQQQ2 On 	#AQQQQQ.Reporte 	= #AQQQQQ2.Reporte 		And
							#AQQQQQ.CodFila 	= #AQQQQQ2.CodFila 		And
							#AQQQQQ.Identificador 	= #AQQQQQ2.Identificador 	And
							#AQQQQQ.Agrupado 	= #AQQQQQ2.Agrupado 	

		Update #AQQQQQ
		Set 	Valor 		= 0,
			Generado 	= GetDate()
		Where Valor Is null And Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 
		
		Update #AQQQQQ
		Set 	Valor 		= Round(Valor, @Redondeo),
			Generado 	= GetDate()
		Where Reporte 	= @Reporte 		And  
					CodFila		= @CodFila		And
					Identificador	= @Identificador	And 
					Agrupado	= @Agrupado 
		
		--Select * from #AQQQQQ

		Truncate Table #AQQQQQ2 
	End
	
	print 'final del loop'
	set @T2 = getdate()
	print cast( datediff(millisecond, @T1, @T2) as varchar(8)) 
	set @T1 = getdate()	

	Fetch Next From curIdentificador Into 	@Reporte, 	@CodFila, 	@Identificador, @Agrupado, @MostrarCuenta, 
					@Formula,	@Procedimiento, @Redondeo,	@Parametros, @PeriodoAnterior
End 
Close 		curIdentificador
Deallocate 	curIdentificador

Update #AQQQQQ
Set 	Valor 		= 0,
	Generado 	= GetDate()
Where Valor Is null

Delete From tCsPrRegulatorios where Reporte = @Regulatorio and dbo.fduFechaAtexto(Fecha, 'AAAAMMDD') = dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')
Insert Into tCsPrRegulatorios
Select 	Fecha = @Fecha, Reporte, dbo.fduRellena(' ', '', (Substring(DescIdentificador, 4, 1)-1)* 2, 'D') + Descripcion as Descripcion, Identificador, DescIdentificador, Agrupado, Nivel, Comentario, DetComentario, 
	Round(Abs(Sum(Valor * Cast((Signo + '1') as int))), Redondeo) as Saldo , OtroDato, Columna, Max(Generado) as Generacion
From #AQQQQQ	
Group by Reporte, Descripcion, DescIdentificador, Identificador, Agrupado, Nivel, Comentario, DetComentario, Redondeo, OtroDato, Columna
Order BY Agrupado

DROP TABLE #AQQQQQ
DROP TABLE #AQQQQQ2
GO