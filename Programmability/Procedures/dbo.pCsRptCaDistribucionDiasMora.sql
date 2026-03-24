SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsRptCaDistribucionDiasMora]
@Fecha 	SmallDateTime,
@Ubicacion	Varchar(100),
@ClaseCartera	Varchar(100),
@Distribucion	Varchar(100),
@TipoSaldo	Varchar(100),
@Select 	Varchar(4000),
@GroupBy 	Varchar(4000)
As

--Set @Fecha 		= '20080831'
--Set @Ubicacion	= 'ZZZ'
--Set @ClaseCartera 	= 'ACTIVA'
--Set @Distribucion	= 'WHERE (Reporte = ''CA02'')' 
--Set @TipoSaldo	= '01'
--Set @Select 		= 'SELECT Detalle.Cartera, Detalle.Fecha, ''Z'' AS Nivel1, ''Saldos del Mes Anterior'' AS Nivel2, tCsPrReportesAnexos.Reporte, ''Z'' AS Identificador '
--Set @GroupBy		= 'GROUP BY Detalle.Cartera, Detalle.Fecha, tCsPrReportesAnexos.Reporte '
----Set @Select 	= 'SELECT Detalle.Cartera, Detalle.Fecha, tCsPrReportesAnexos.Identificador AS Nivel1, tCsPrReportesAnexos.Descripcion AS Nivel2, tCsPrReportesAnexos.Reporte, tCsPrReportesAnexos.Identificador AS Identificador '
----Set @GroupBy	= 'GROUP BY Detalle.Cartera, Detalle.Fecha, tCsPrReportesAnexos.Reporte, tCsPrReportesAnexos.Identificador, tCsPrReportesAnexos.Descripcion '

Declare @Cadena		Varchar(4000)
	
Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera 	Varchar(500)
Declare @CDistribucion 		Varchar(500)

Declare @Tabla 		Varchar(50)
Declare @DSelect		Varchar(4000)
Declare @DFrom1		Varchar(4000)
Declare @DFrom2		Varchar(4000)
Declare @DFrom3		Varchar(4000)
Declare @DWhere		Varchar(4000)
Declare @DGroupBy		Varchar(4000)
Declare @OtroDato		Varchar(100)

Declare @CDetalle1 		Varchar(4000)
Declare @CDetalle2 		Varchar(4000)
Declare @CDetalle3 		Varchar(4000)

Declare @Select1 		Varchar(4000)
Declare @GroupBy1 		Varchar(4000)

Declare @Concepto		Varchar(100)
Declare @CConceptos1 		Varchar(4000)
Declare @CConceptos2 		Varchar(4000)
Declare @CConceptos3 		Varchar(4000)

Declare @MesAnterior		SmallDateTime

Declare @Campo 		Varchar(4000)
Declare @Sumatoria		Varchar(4000)
Declare @Identificador 		Varchar(10)
Declare @Padre 		Varchar(10)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 	Out, 	@Tabla 		Out,  @OtroDato Out
Exec pGnlCalculaParametros 4, @Distribucion, 	@CDistribucion 	Out, 	@Distribucion		Out,  @OtroDato Out

Print 'DISTRIBUCION'
Print @CDistribucion

Exec pCsRptCaDetalleCartera 	@Fecha, @CUbicacion, @Ubicacion, @CClaseCartera, @ClaseCartera, @Tabla,
				@DSelect 	Out,
				@DFrom1	Out,
				@DFrom2	Out,
				@DFrom3	Out,
				@DWhere 	Out,
				@DGroupBy	Out

Set @CDetalle1 		=  'FROM ( '  +  @DSelect + @DFrom1 
Set @CDetalle2 		=  @DFrom2 + @DFrom3 
Set @CDetalle3 		=  @DWhere + @DGroupBy + ') Detalle INNER JOIN (SELECT * FROM tCsPrReportesAnexos '+ @CDistribucion +') tCsPrReportesAnexos ON tCsPrReportesAnexos.PInicio <= Detalle.Dias AND tCsPrReportesAnexos.PFin >= Detalle.Dias '

Print 'CDetalle1 = ' + Cast(Len(@CDetalle1) as Varchar(100))
Print 'CDetalle2 = ' + Cast(Len(@CDetalle2) as Varchar(100))
Print 'CDetalle3 = ' + Cast(Len(@CDetalle3) as Varchar(100))

Print @Select
Print @CDetalle1
Print @CDetalle2
Print @CDetalle3

CREATE TABLE #tRptSituacionCarteraContador (
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha] [smalldatetime] NULL ,
	[Nivel1] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel2] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Reporte] [varchar] (5) COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] [varchar] (10) COLLATE Modern_Spanish_CI_AI NULL ,
	[DI] [Int] NULL,
	[DF] [Int] NULL,
	[Concepto] [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL ,
	[Contador] [decimal] (18,4) NULL )
	
-- PARA CONTAR CLIENTES Y PRESTAMOS	
Set @Concepto	= 'CodUsuario'
Set @Select1 	= ', Detalle.' + @Concepto + ' '
Set @GroupBy1 = ', Detalle.' + @Concepto

Set @CConceptos1  	= 'Insert Into #tRptSituacionCarteraContador SELECT Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, DI, DF, Concepto = '''+ @Concepto +''', COUNT(*) AS Contador FROM ( ' + @Select + @Select1 
Set @CConceptos2	= @CDetalle2  
Set @CConceptos3	= @CDetalle3 + @GroupBy + @GroupBy1 + ')' + @Concepto + ' GROUP BY Cartera, Fecha, Nivel1, Nivel2, reporte, Identificador, DI, DF '
Print 	'CONTANDO CLIENTES'
Print  	@CConceptos1 
Print 	@CDetalle1
Print 	@CConceptos2 
Print 	@CConceptos3

Print '@CConceptos1 = ' + Cast(Len(@CConceptos1) as Varchar(100))
Print '@CConceptos2 = ' + Cast(Len(@CConceptos2) as Varchar(100))
Print '@CConceptos3 = ' + Cast(Len(@CConceptos3) as Varchar(100))

Exec    (@CConceptos1 + @CDetalle1 + @CConceptos2 + @CConceptos3)

Set @Concepto	= 'CodAsesor'
Set @Select1 	= ', Detalle.' + @Concepto + ' '
Set @GroupBy1 = ', Detalle.' + @Concepto

Set @CConceptos1  	= 'Insert Into #tRptSituacionCarteraContador SELECT Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, DI, DF, Concepto = '''+ @Concepto +''', COUNT(*) AS Contador FROM ( ' + @Select + @Select1 
Set @CConceptos2	= @CDetalle2  
Set @CConceptos3	= @CDetalle3 + @GroupBy + @GroupBy1 + ')' + @Concepto + ' GROUP BY Cartera, Fecha, Nivel1, Nivel2, reporte, Identificador, DI, DF '
Print 	'CONTANDO ASESORES'
Print  	@CConceptos1 
Print 	@CDetalle1
Print 	@CConceptos2 
Print 	@CConceptos3

Print '@CConceptos1 = ' + Cast(Len(@CConceptos1) as Varchar(100))
Print '@CConceptos2 = ' + Cast(Len(@CConceptos2) as Varchar(100))
Print '@CConceptos3 = ' + Cast(Len(@CConceptos3) as Varchar(100))

Exec    (@CConceptos1 + @CDetalle1 + @CConceptos2 + @CConceptos3)

Set @Concepto	= 'Total'
Set @Select1 	= ', ''' + @Concepto + ''' As Concepto, Sum(' + @TipoSaldo + ') As Saldo '
Set @GroupBy1 	= ''

Set @CConceptos1  	= 'Insert Into #tRptSituacionCarteraContador ' + @Select + @Select1 
Set @CConceptos2	= @CDetalle2  
Set @CConceptos3	= @CDetalle3 + @GroupBy + @GroupBy1 
Print 	'CONTANDO SALDO'
Print  	@CConceptos1 
Print 	@CDetalle1
Print 	@CConceptos2 
Print 	@CConceptos3

Print '@CConceptos1 = ' + Cast(Len(@CConceptos1) as Varchar(100))
Print '@CConceptos2 = ' + Cast(Len(@CConceptos2) as Varchar(100))
Print '@CConceptos3 = ' + Cast(Len(@CConceptos3) as Varchar(100))

Exec    (@CConceptos1 + @CDetalle1 + @CConceptos2 + @CConceptos3)

CREATE TABLE #DatosBasicos (
	[Cartera] [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL ,
	[Fecha] [smalldatetime] NULL ,
	[Nivel1] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Nivel2] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL ,
	[Reporte] [varchar] (5) COLLATE Modern_Spanish_CI_AI NULL ,
	[Identificador] [varchar] (10) COLLATE Modern_Spanish_CI_AI NULL ,
	[DI] [Int] NULL,
	[DF] [Int] NULL,
	[ZCodUsuario] [decimal](38, 4) NULL ,
	[ZCodAsesor] [decimal](38, 4) NULL ,
	[ZTotal] [decimal](38, 4) NULL) 

Declare curPadre Cursor For
	SELECT DISTINCT Identificador
	FROM  #tRptSituacionCarteraContador       
	ORDER BY Identificador
Open curPadre
Fetch Next From curPadre Into @Padre
While @@Fetch_Status = 0
Begin 	

	Set @Campo 	= ''
	Set @Sumatoria	= ''
	
	Declare curIdentificador Cursor For 
		SELECT     Concepto, Identificador
		FROM         #tRptSituacionCarteraContador
		WHERE 	Identificador = @Padre
	Open curIdentificador
	Fetch Next From curIdentificador Into @Identificador, @OtroDato
	While @@Fetch_Status = 0
	Begin 	
		--Print 'COMENZANDO BUCLE'
		Set @Campo 	= @Campo + 'CASE WHEN Concepto = '''+ @Identificador +''' THEN Contador ELSE 0 END AS '+ @OtroDato + @Identificador + ', '
			
		Set @Sumatoria	= @Sumatoria + 'SUM('+ @OtroDato + @Identificador + ') AS '+ @OtroDato + @Identificador +', '
			
	Fetch Next From curIdentificador Into  @Identificador, @OtroDato
	End 
	Close 		curIdentificador
	Deallocate 	curIdentificador
	
	Set @Campo 	= Substring(Ltrim(Rtrim(@Campo)), 1, Len(Ltrim(Rtrim(@Campo))) - 1) + ' '
	Set @Sumatoria 	= Substring(Ltrim(Rtrim(@Sumatoria)), 1, Len(Ltrim(Rtrim(@Sumatoria))) - 1) + ' '
	
	Set @Cadena = 'INSERT INTO #DatosBasicos SELECT Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, DI, DF, ' + @Sumatoria + ' '
	Set @Cadena = @Cadena + 'FROM (SELECT Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, DI, DF, ' + @Campo + ' '
	Set @Cadena = @Cadena + 'FROM  #tRptSituacionCarteraContador WHERE Identificador = '''+ @Padre +''') Datos '
	Set @Cadena = @Cadena + 'GROUP BY Cartera, Fecha, Nivel1, Nivel2, Reporte, Identificador, DI, DF'
	
	Print @Cadena
	Exec(@Cadena)

Fetch Next From curPadre Into  @Padre
End 
Close 		curPadre
Deallocate 	curPadre

Select * From #DatosBasicos

DROP TABLE #tRptSituacionCarteraContador
DROP TABLE #DatosBasicos
GO