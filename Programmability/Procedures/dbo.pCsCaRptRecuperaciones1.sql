SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--DROP PROCEDURE [dbo].[pCsCaRptRecuperaciones1]
CREATE PROCEDURE [dbo].[pCsCaRptRecuperaciones1]
@Dato		Int, 
@FecIni 	SmallDateTime, 
@FecFin 	SmallDateTime,
@Ubicacion	Varchar(500),
@Agrupado1	Varchar(100),
@Agrupado2	Varchar(100),
@ClaseCartera	Varchar(500)
AS
--1: Recuperaciones
--2: Desembolsos
--3: Condonaciones
--4: Devengado
--5: Castigos
--6: Combinar
--7: Resumen

Declare @TempF		SmallDateTime
Declare @TempI		SmallDateTime
Declare @Cadena1 	Varchar (4000)
Declare @Cadena2 	Varchar (4000)
Declare @Cadena3 	Varchar (4000)
Declare @Cadena4 	Varchar (4000)
Declare @Cadena5 	Varchar (4000)
Declare @Cadena6 	Varchar (4000)

Declare @Recuperaciones	Varchar (4000)
Declare @Desembolsos	Varchar (4000)
Declare @Condonaciones	Varchar (4000)
Declare @Devengado		Varchar (4000)
Declare @Castigos		Varchar (4000)

Declare @Titulo 	Char 	(50)

If @FecIni > @FecFin
Begin
	Set @TempF 	= @FecFin
	Set @FecFin = @FecIni
	Set @FecIni = @TempF
End 

Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera 	Varchar(500)
Declare @CAgrupado1 	Char(50)
Declare @CAgrupado2 	Char(50)

Declare @OtroDato	Varchar(100)
Declare @CDato 		Varchar(100)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out

SELECT @CAgrupado1 = Cartera FROM tCsPrNivel WHERE (Nivel = @Agrupado1)
SELECT @CAgrupado2 = Cartera FROM tCsPrNivel WHERE (Nivel = @Agrupado2)

IF Ltrim(Rtrim(Isnull(@CAgrupado1, ''))) = '' Begin Set @CAgrupado1 = @Agrupado1 End
IF Ltrim(Rtrim(Isnull(@CAgrupado2, ''))) = '' Begin Set @CAgrupado2 = @Agrupado2 End

Create Table #A (
Fecha		SmallDateTime,
CodOficina	Varchar(4),
CodPrestamo	Varchar(25),
CodUsuario	Varchar(15),
Capital		Decimal(18,4),
Intereses	Decimal(18,4)
)
Set 	@TempI 		= @Dato
Set 	@Dato		= @Dato%10
Set 	@Cadena4 	= 'SELECT Fecha, CodOficina, CodPrestamo, CodUsuario, '
If 	@Dato 		= 6 -- Para Combinar 
Begin 
	Set @Cadena4 = @Cadena4 + 'SUM(Capital) * -1 AS Capital, SUM(Interes) * -1 AS Intereses FROM ('
End
Else
Begin
	Set @Cadena4 = @Cadena4 + 'SUM(Capital) AS Capital, SUM(Interes) AS Intereses FROM ('
End
Set @Cadena5 = ') Datos GROUP BY Fecha, CodOficina, CodPrestamo, CodUsuario'

Set @Recuperaciones = 'SELECT Fecha, '
Set @Recuperaciones = @Recuperaciones + 'CodOficina, CodPrestamo, CodUsuario, CASE WHEN CodConcepto IN (''CAPI'') THEN SUM(MontoPagado) ELSE 0 END AS Capital, CASE '
Set @Recuperaciones = @Recuperaciones + 'WHEN CodConcepto NOT IN (''CAPI'') THEN SUM(MontoPagado) ELSE 0 END AS Interes FROM tCsPagoDet WHERE (Fecha >= ''' 
Set @Recuperaciones = @Recuperaciones + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND (Extornado = 0) AND (Fecha <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') 
Set @Recuperaciones = @Recuperaciones + ''') AND (CodConcepto IN (''CAPI'', ''INTE'', ''INPE'')) AND CodOficina IN ('+ @CUbicacion +') GROUP BY Fecha, CodOficina, '
Set @Recuperaciones = @Recuperaciones + 'CodPrestamo, CodUsuario, CodConcepto'

Set @Desembolsos	= 'SELECT Desembolso AS Fecha, CodOficina, CodPrestamo, CodUsuario, Monto AS Capital, 0 AS Intereses '
Set @Desembolsos	= @Desembolsos + 'FROM tCsPadronCarteraDet WHERE (Desembolso >= ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND '
Set @Desembolsos	= @Desembolsos + '(Desembolso <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') AND (CodOficina IN ('+ @CUbicacion +'))'

Set @Condonaciones	= 'SELECT tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodOficina, '
Set @Condonaciones	= @Condonaciones + 'tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodUsuario, CASE WHEN '
Set @Condonaciones	= @Condonaciones + 'CodConcepto IN (''CAPI'') THEN SUM(tCsOpRecuperablesDet.MontoOp) ELSE 0 END AS '
Set @Condonaciones	= @Condonaciones + 'Capital, CASE WHEN CodConcepto NOT IN (''CAPI'') THEN SUM(tCsOpRecuperablesDet.'
Set @Condonaciones	= @Condonaciones + 'MontoOp) ELSE 0 END AS Interes FROM tCsOpRecuperablesDet INNER JOIN '
Set @Condonaciones	= @Condonaciones + 'tCsOpRecuperables ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND '
Set @Condonaciones	= @Condonaciones + 'tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND '
Set @Condonaciones	= @Condonaciones + 'tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND '
Set @Condonaciones	= @Condonaciones + 'tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo WHERE '
Set @Condonaciones	= @Condonaciones + '(tCsOpRecuperablesDet.CodConcepto IN (''CAPI'', ''INTE'', ''INPE'')) AND '
Set @Condonaciones	= @Condonaciones + '(tCsOpRecuperablesDet.Fecha >= ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND '
Set @Condonaciones	= @Condonaciones + '(tCsOpRecuperablesDet.Fecha <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') AND '
Set @Condonaciones	= @Condonaciones + '(tCsOpRecuperables.TipoOp = ''002'') AND (tCsOpRecuperablesDet.CodOficina IN '
Set @Condonaciones	= @Condonaciones + '('+ @CUbicacion +'))GROUP BY tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.'
Set @Condonaciones	= @Condonaciones + 'CodOficina, tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodUsuario, '
Set @Condonaciones	= @Condonaciones + 'tCsOpRecuperablesDet.CodConcepto'

Set @Castigos		= 'SELECT tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.CodOficina, '
Set @Castigos		= @Castigos + 'tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodUsuario, CASE WHEN '
Set @Castigos		= @Castigos + 'CodConcepto IN (''CAPI'') THEN SUM(tCsOpRecuperablesDet.MontoOp) ELSE 0 END AS '
Set @Castigos		= @Castigos + 'Capital, CASE WHEN CodConcepto NOT IN (''CAPI'') THEN SUM(tCsOpRecuperablesDet.'
Set @Castigos		= @Castigos + 'MontoOp) ELSE 0 END AS Interes FROM tCsOpRecuperablesDet INNER JOIN '
Set @Castigos		= @Castigos + 'tCsOpRecuperables ON tCsOpRecuperablesDet.Fecha = tCsOpRecuperables.Fecha AND '
Set @Castigos		= @Castigos + 'tCsOpRecuperablesDet.CodOficina = tCsOpRecuperables.CodOficina AND '
Set @Castigos		= @Castigos + 'tCsOpRecuperablesDet.SecPago = tCsOpRecuperables.SecPago AND '
Set @Castigos		= @Castigos + 'tCsOpRecuperablesDet.CodPrestamo = tCsOpRecuperables.CodPrestamo WHERE '
Set @Castigos		= @Castigos + '(tCsOpRecuperablesDet.CodConcepto IN (''CAPI'', ''INTE'', ''INPE'')) AND '
Set @Castigos		= @Castigos + '(tCsOpRecuperablesDet.Fecha >= ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND '
Set @Castigos		= @Castigos + '(tCsOpRecuperablesDet.Fecha <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') AND '
Set @Castigos		= @Castigos + '(tCsOpRecuperables.TipoOp = ''003'') AND (tCsOpRecuperablesDet.CodOficina IN '
Set @Castigos		= @Castigos + '('+ @CUbicacion +'))GROUP BY tCsOpRecuperablesDet.Fecha, tCsOpRecuperablesDet.'
Set @Castigos		= @Castigos + 'CodOficina, tCsOpRecuperablesDet.CodPrestamo, tCsOpRecuperablesDet.CodUsuario, '
Set @Castigos		= @Castigos + 'tCsOpRecuperablesDet.CodConcepto'

Set @Devengado		= 'SELECT Fecha, CodOficina, CodPrestamo, CodUsuario, Capital = 0, InteresDevengado + '
Set @Devengado		= @Devengado + 'MoratorioDevengado As Interes FROM (SELECT Detalle.CodOficina, Detalle.Fecha, '
Set @Devengado		= @Devengado + 'Detalle.CodPrestamo, Detalle.CodUsuario, Detalle.Interes, tCsCarteraDet_1.'
Set @Devengado		= @Devengado + 'InteresVigente + tCsCarteraDet_1.InteresVencido AS InteresA, Detalle.'
Set @Devengado		= @Devengado + 'InteresCtaOrden, tCsCarteraDet_1.InteresCtaOrden AS InteresCtaOrdenA, Detalle.'
Set @Devengado		= @Devengado + 'InteresDevengado, Detalle.Moratorio, tCsCarteraDet_1.MoratorioVigente + '
Set @Devengado		= @Devengado + 'tCsCarteraDet_1.MoratorioVencido AS MoratorioA, Detalle.MoratorioCtaOrden, '
Set @Devengado		= @Devengado + 'tCsCarteraDet_1.MoratorioCtaOrden AS MoratorioCtaOrdenA, Detalle.MoratorioDevengado '
Set @Devengado		= @Devengado + 'FROM ('
Set @Devengado		= @Devengado + 'SELECT CodOficina, Fecha, CodPrestamo, CodUsuario, InteresVigente + InteresVencido '
Set @Devengado		= @Devengado + 'AS Interes, InteresCtaOrden, InteresDevengado, MoratorioVigente + MoratorioVencido '
Set @Devengado		= @Devengado + 'AS Moratorio, MoratorioCtaOrden, MoratorioDevengado FROM tCsCarteraDet WHERE (Fecha '
Set @Devengado		= @Devengado + '>= ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND (Fecha '
Set @Devengado		= @Devengado + '<= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') AND (CodOficina IN '
Set @Devengado		= @Devengado + '('+ @CUbicacion +')) '
Set @Devengado		= @Devengado + ') Detalle LEFT OUTER JOIN tCsCarteraDet AS tCsCarteraDet_1 ON Detalle.Fecha = '
Set @Devengado		= @Devengado + 'tCsCarteraDet_1.Fecha + 1 AND Detalle.CodPrestamo = tCsCarteraDet_1.CodPrestamo '
Set @Devengado		= @Devengado + 'AND Detalle.CodUsuario = tCsCarteraDet_1.CodUsuario) AS Datos WHERE InteresDevengado + MoratorioDevengado <> 0 '
----
Set @Recuperaciones 	= @Cadena4 + @Recuperaciones	+ @Cadena5
Set @Condonaciones	= @Cadena4 + @Condonaciones	+ @Cadena5
Set @Castigos		= @Cadena4 + @Castigos		+ @Cadena5
Set @Cadena4		= 'SELECT Fecha, CodOficina, CodPrestamo, CodUsuario, SUM(Capital) AS Capital, SUM(Interes) AS Intereses FROM ('
Set @Devengado		= @Cadena4 + @Devengado		+ @Cadena5

If @Dato in (1, 6) 
Begin 
	Set @Titulo	= 'RECUPERACIONES'
	Set @Cadena6	= 'Insert Into #A ' + @Recuperaciones 
	Exec (@Cadena6)		
	Print @Titulo
	Print @Cadena6
End
If @Dato in (2, 6) 
Begin 
	Set @Titulo	= 'DESEMBOLSOS'
	Set @Cadena6	= 'Insert Into #A ' + @Desembolsos
	Exec (@Cadena6)
	Print @Titulo
	Print @Cadena6
End
If @Dato in (3, 6) 
Begin 
	Set @Titulo	= 'CONDONACIONES'
	Set @Cadena6	= 'Insert Into #A ' + @Condonaciones
	Exec (@Cadena6)
	Print @Titulo
	Print @Cadena6
End
If @Dato in (4, 6) 
Begin 
	Set @Titulo	= 'DEVENGADO'
	Set @Cadena6	= 'Insert Into #A ' + @DEVENGADO
	Exec (@Cadena6)
	Print @Titulo
	Print @Cadena6
End
If @Dato in (5, 6)
Begin
	Set @Titulo	= 'CASTIGOS'
	Set @Cadena6	= 'Insert Into #A ' + @Castigos
	Exec (@Cadena6)
	Print @Titulo
	Print @Cadena6
End
If @Dato = 6 -- Para Combinar 
Begin 
	Set @Titulo	= 'COMBINAR (Rec., Des., Con., Dev. y Cas.)'
End

CREATE TABLE #EEEE (
	[Inicio] [smalldatetime] NULL ,
	[Fin] [smalldatetime] NULL ,
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Cartera] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[Estado] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[CodFondo] [tinyint] NULL ,
	[CodAsesor] [varchar] (15) COLLATE Modern_Spanish_CI_AI NULL ,
	[CodTipoCredito] [tinyint] NULL ,
	[CodProducto] [smallint] NULL ,
	[G] [varchar] (16) COLLATE Modern_Spanish_CI_AI NOT NULL) 

CREATE TABLE #MMMM (
	[Inicio] [smalldatetime] NULL ,
	[Fin] [smalldatetime] NULL ,
	[Codigo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[G] [varchar] (13) COLLATE Modern_Spanish_CI_AI NOT NULL ) 

Set @Cadena4 = 'Insert Into #EEEE SELECT MIN(Fecha) AS Inicio, MAX(Fecha) AS Fin, CodPrestamo, Cartera, Estado, CodFondo, CodAsesor, CodTipoCredito, '
Set @Cadena4 = @Cadena4 + 'CodProducto, G = ''Calculo Garantía'' FROM tCsCartera WHERE (Cartera IN ('+ @CClaseCartera +')) AND (Fecha '
Set @Cadena4 = @Cadena4 + '>= ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND (Fecha <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') '
Set @Cadena4 = @Cadena4 + 'AND (CodPrestamo IN (SELECT DISTINCT Codprestamo FROM #A)) GROUP BY CodPrestamo, Cartera, Estado, CodFondo, CodAsesor, '
Set @Cadena4 = @Cadena4 + 'CodTipoCredito, CodProducto '

Print @Cadena4
Exec (@Cadena4)

Set @Cadena4 = 'Insert Into #EEEE SELECT DISTINCT tCsPadronCarteraDet.Cancelacion AS Inicio, tCsPadronCarteraDet.Cancelacion AS Fin, '
Set @Cadena4 = @Cadena4 + 'tCsPadronCarteraDet.CodPrestamo, tCsCartera.Cartera, tCsCartera.Estado, tCsCartera.CodFondo, tCsCartera.CodAsesor, '
Set @Cadena4 = @Cadena4 + 'tCsCartera.CodTipoCredito, tCsPadronCarteraDet.CodProducto, G = ''Calculo Garantía'' FROM tCsPadronCarteraDet INNER JOIN '
Set @Cadena4 = @Cadena4 + 'tCsCartera ON tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo '
Set @Cadena4 = @Cadena4 + 'WHERE (tCsPadronCarteraDet.Cancelacion = ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND '
Set @Cadena4 = @Cadena4 + '(tCsCartera.Cartera IN ('+ @CClaseCartera +'))' --AND (tCsPadronCarteraDet.CodPrestamo NOT IN (SELECT Codprestamo FROM #EEEE))'

Print @Cadena4
Exec (@Cadena4)

Set @Cadena4 = 'Insert Into #EEEE SELECT DISTINCT tCsPadronCarteraDet.PaseCastigado AS Inicio, tCsPadronCarteraDet.PaseCastigado AS Fin, '
Set @Cadena4 = @Cadena4 + 'tCsPadronCarteraDet.CodPrestamo, tCsCartera.Cartera, tCsCartera.Estado, tCsCartera.CodFondo, '
Set @Cadena4 = @Cadena4 + 'tCsCartera.CodAsesor, tCsCartera.CodTipoCredito, tCsPadronCarteraDet.CodProducto, '
Set @Cadena4 = @Cadena4 + 'G = ''Calculo Garantía'' FROM tCsPadronCarteraDet INNER JOIN tCsCartera ON '
Set @Cadena4 = @Cadena4 + 'tCsPadronCarteraDet.PaseCastigado - 1 = tCsCartera.Fecha AND tCsPadronCarteraDet.CodPrestamo '
Set @Cadena4 = @Cadena4 + '= tCsCartera.CodPrestamo WHERE (tCsPadronCarteraDet.PaseCastigado >= ''' + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND '
Set @Cadena4 = @Cadena4 + '(tCsPadronCarteraDet.PaseCastigado <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') '
Set @Cadena4 = @Cadena4 + 'And (tCsPadronCarteraDet.CarteraOrigen IN ('+ @CClaseCartera +'))'

Print @Cadena4
Exec (@Cadena4)

Set @Cadena4 = 'Insert Into #MMMM SELECT MIN(Fecha) AS Inicio, MAX(Fecha) AS Fin, Codigo, ''Prendaria    '' AS G FROM tCsDiaGarantias WHERE (Fecha >= '''
Set @Cadena4 = @Cadena4 + dbo.fdufechaatexto(@FecIni, 'AAAAMMDD') + ''') AND (Fecha <= ''' + dbo.fdufechaatexto(@FecFin, 'AAAAMMDD') + ''') And '
Set @Cadena4 = @Cadena4 + '(Codigo IN (SELECT DISTINCT Codprestamo FROM #A)) GROUP BY Codigo'

Print @Cadena4
Exec (@Cadena4)

Update #EEEE Set G = ''

UPDATE    #EEEE
SET              G = #MMMM.G
FROM         #MMMM INNER JOIN
                      #EEEE ON #MMMM.Codigo = #EEEE.CodPrestamo AND #MMMM.Inicio = #EEEE.Inicio AND #MMMM.Fin = #EEEE.Fin
WHERE     (ltrim(rtrim(isnull(#EEEE.G, ''))) = '')

UPDATE    #EEEE
SET              G = #MMMM.G
FROM         #EEEE INNER JOIN
                      #MMMM ON #EEEE.CodPrestamo = #MMMM.Codigo AND #EEEE.Inicio = #MMMM.Inicio AND #EEEE.Fin <= #MMMM.Fin
WHERE     (ltrim(rtrim(isnull(#EEEE.G, ''))) = '')

UPDATE    #EEEE
SET              G = #MMMM.G
FROM         #EEEE INNER JOIN
                      #MMMM ON #EEEE.CodPrestamo = #MMMM.Codigo AND #EEEE.Fin = #MMMM.Fin AND #EEEE.Inicio >= #MMMM.Inicio
WHERE     (ltrim(rtrim(isnull(#EEEE.G, ''))) = '')

UPDATE    #EEEE
SET              G = #MMMM.G
FROM         #EEEE INNER JOIN
                      #MMMM ON #EEEE.CodPrestamo = #MMMM.Codigo AND #EEEE.Inicio >= #MMMM.Inicio AND #EEEE.Fin <= #MMMM.Fin
WHERE     (ltrim(rtrim(isnull(#EEEE.G, ''))) = '')

Insert Into #EEEE
SELECT DISTINCT 
                      #EEEE.Inicio, #MMMM.Inicio AS Fin, #EEEE.CodPrestamo, #EEEE.Cartera, #EEEE.Estado, #EEEE.CodFondo, #EEEE.CodAsesor, #EEEE.CodTipoCredito, 
                      #EEEE.CodProducto, G = 'Quirografaria'
FROM         #EEEE INNER JOIN
                      #MMMM ON #EEEE.CodPrestamo = #MMMM.Codigo
WHERE     (ltrim(rtrim(isnull(#EEEE.G, ''))) = '')

Insert Into #EEEE
SELECT DISTINCT 
                      #MMMM.Inicio + 1 AS Inicio, #EEEE.Fin AS Fin, #EEEE.CodPrestamo, #EEEE.Cartera, #EEEE.Estado, #EEEE.CodFondo, #EEEE.CodAsesor, #EEEE.CodTipoCredito, 
                      #EEEE.CodProducto, #MMMM.G
FROM         #EEEE INNER JOIN
                      #MMMM ON #EEEE.CodPrestamo = #MMMM.Codigo
WHERE     (ltrim(rtrim(isnull(#EEEE.G, ''))) = '')

DELETE FROM #EEEE
WHERE     ((CAST(Inicio AS varchar(100)) + CAST(Fin AS varchar(100)) + CodPrestamo) IN
                          (SELECT     CAST(#EEEE.Inicio AS varchar(100)) + CAST(#EEEE.Fin AS varchar(100)) + #EEEE.CodPrestamo
                            FROM          #EEEE INNER JOIN
                                                   #MMMM ON #EEEE.CodPrestamo = #MMMM.Codigo
                            WHERE      (LTRIM(RTRIM(ISNULL(#EEEE.G, ''))) = '')))

UPDATE    #EEEE
SET              G = 'Quirografaria'
WHERE     (LTRIM(RTRIM(G)) = '')

UPDATE    #EEEE
SET              Fin = tCsPadronCarteraDet.Cancelacion
FROM         #EEEE INNER JOIN
                      tCsPadronCarteraDet ON #EEEE.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND #EEEE.Fin + 1 = tCsPadronCarteraDet.Cancelacion

Set @Cadena3 = 'Select * From #A'

Set @Cadena1 = 'SELECT Titulo = '''+ @Titulo +''', Nivel1 = '''+ @CAgrupado1 +''', Nivel2 = '''+ @CAgrupado2 +''', '+ @Agrupado1 +' as Agrupado1, '
Set @Cadena1 = @Cadena1 + @Agrupado2 +' as Agrupado2, ' + CASE WHEN @Dato <> 7 Then 'Fecha,' Else '' END + ' SUM(CAPITAL) AS CAPITAL, SUM(INTERESES) AS INTERESES, '
Set @Cadena1 = @Cadena1 + 'SUM(MontoTotalTran) AS MontoTotalTran, '
Set @Cadena1 = @Cadena1 + 'COUNT(DISTINCT CodPrestamo) AS NroPtmos FROM (SELECT dbo.fduRellena(''0'', rtrim(Ltrim(Transacciones.CodOficina)), 2, ''D'') + '' '' + '
Set @Cadena1 = @Cadena1 + 'ISNULL(Rtrim(Ltrim(tClOficinas.NomOficina)), ''No Especificada'') AS Oficina, tCaClTecnologia.Veridico AS Tecnologia, '
Set @Cadena1 = @Cadena1 + 'tCsPadronClientes.Paterno + '' '' + tCsPadronClientes.Materno + '', '' + tCsPadronClientes.Nombre1 AS Asesor, '
Set @Cadena1 = @Cadena1 + 'Transacciones.Fecha, Transacciones.Capital, Transacciones.Intereses, Transacciones.Capital + Transacciones.Intereses AS '
Set @Cadena1 = @Cadena1 + 'MontoTotalTran, Transacciones.CodPrestamo, EEEE.Cartera AS ClaseCartera, ISNULL(tCPClEstado.Estado, ''No Especificado'''
Set @Cadena1 = @Cadena1 + ') AS CP1_Estado, ISNULL(tCPClMunicipio.Municipio, ''No Especificado'') AS CP2_Municipio, ISNULL(tCPLugar.Lugar, '
Set @Cadena1 = @Cadena1 + '''No Especificado'') AS CP3_Colonia, dbo.fduEdad(tCsPadronClientes_1.FechaNacimiento, Transacciones.Fecha) AS Edad, '
Set @Cadena1 = @Cadena1 + 'EEEE.Estado, ISNULL(tClFondos.NemFondo, ''No Especificado'') AS Fondo, ISNULL(tUsClSexo.Genero, ''No Especificado'') AS '
Set @Cadena1 = @Cadena1 + 'Genero, ISNULL(EEEE.G, ''Quirografaria'') AS OperacionGarantia, ''['' + dbo.fduFechaATexto(tCsPadronCarteraDet.Desembolso, '
Set @Cadena1 = @Cadena1 + '''AAAAMM'') + '']-'' + DATENAME([month], tCsPadronCarteraDet.Desembolso) AS PeriodoDesembolso, tCaProducto.NombreProdCorto AS '
Set @Cadena1 = @Cadena1 + 'Producto, tClZona.Nombre AS Regional, ''Secuencia Cliente '' + dbo.fduRellena(''0'', tCsPadronCarteraDet.SecuenciaCliente, 2, '
Set @Cadena1 = @Cadena1 + '''D'') AS SecuenciaCliente, ''Secuencia Grupo '' + dbo.fduRellena(''0'', tCsPadronCarteraDet.SecuenciaGrupo, 2, ''D'') AS '
Set @Cadena1 = @Cadena1 + 'SecuenciaGrupo, ISNULL(tCaProdPerTipoCredito.Descripcion, ''No Especificado'') AS TipoCredito, tCPLugar.Zona AS ZonaLugar '
Set @Cadena1 = @Cadena1 + 'FROM tClFondos RIGHT OUTER JOIN tCaProdPerTipoCredito RIGHT OUTER JOIN tCaClTecnologia INNER JOIN tCaProducto ON '
Set @Cadena1 = @Cadena1 + 'tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia RIGHT OUTER JOIN #EEEE EEEE INNER JOIN ( '
Set @Cadena2 = ') Transacciones ON EEEE.Inicio <= Transacciones.Fecha AND EEEE.Fin >= Transacciones.Fecha AND EEEE.CodPrestamo = '
Set @Cadena2 = @Cadena2 + 'Transacciones.CodPrestamo LEFT OUTER JOIN tCPClEstado INNER JOIN tCPClMunicipio ON tCPClEstado.CodEstado = '
Set @Cadena2 = @Cadena2 + 'tCPClMunicipio.CodEstado INNER JOIN tCPLugar ON tCPClMunicipio.CodMunicipio = tCPLugar.CodMunicipio AND '
Set @Cadena2 = @Cadena2 + 'tCPClMunicipio.CodEstado = tCPLugar.CodEstado INNER JOIN tClUbigeo INNER JOIN tCsPadronCarteraDet INNER JOIN '
Set @Cadena2 = @Cadena2 + 'tCsPadronClientes tCsPadronClientes_1 ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes_1.CodUsuario ON '
Set @Cadena2 = @Cadena2 + 'tClUbigeo.CodUbiGeo = ISNULL(tCsPadronClientes_1.CodUbiGeoDirFamPri, tCsPadronClientes_1.CodUbiGeoDirNegPri) ON '
Set @Cadena2 = @Cadena2 + 'tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND tCPLugar.CodEstado = tClUbigeo.CodEstado AND tCPLugar.IdLugar = '
Set @Cadena2 = @Cadena2 + 'tClUbigeo.IdLugar INNER JOIN tUsClSexo ON tCsPadronClientes_1.Sexo = tUsClSexo.Sexo ON Transacciones.CodPrestamo COLLATE '
Set @Cadena2 = @Cadena2 + 'Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND Transacciones.CodUsuario COLLATE Modern_Spanish_CI_AI = '
Set @Cadena2 = @Cadena2 + 'tCsPadronCarteraDet.CodUsuario LEFT OUTER JOIN tClZona INNER JOIN tClOficinas ON tClZona.Zona = tClOficinas.Zona ON '
Set @Cadena2 = @Cadena2 + 'Transacciones.CodOficina COLLATE Modern_Spanish_CI_AI = tClOficinas.CodOficina ON tCaProducto.CodProducto = '
Set @Cadena2 = @Cadena2 + 'EEEE.CodProducto LEFT OUTER JOIN tCsPadronClientes ON EEEE.CodAsesor = tCsPadronClientes.CodUsuario ON '
Set @Cadena2 = @Cadena2 + 'tCaProdPerTipoCredito.CodTipoCredito = EEEE.CodTipoCredito ON tClFondos.CodFondo = EEEE.CodFondo) A GROUP BY ' + CASE WHEN @Dato <> 7 Then 'Fecha, ' Else '' END + @Agrupado1 +', '+ @Agrupado2 +''
               
Print @Cadena1 
Print @Cadena3 
Print @Cadena2
Exec (@Cadena1 + @Cadena3 + @Cadena2)
Drop Table #A
Drop Table #EEEE
Drop Table #MMMM
GO