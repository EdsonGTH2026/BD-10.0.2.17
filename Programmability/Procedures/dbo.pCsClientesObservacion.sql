SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsClientesObservacion
CREATE Procedure [dbo].[pCsClientesObservacion]
@Ubicacion	Varchar(100),
@Observacion	Varchar(100),
@Dato		Int
AS
--VARIABLES DEL PROCEDIMIENTO
Declare @CUbicacion	Varchar(500)
Declare @CObservacion	Varchar(500)
Declare @OtroDato	Varchar(100)

Declare @Cadena1 	Varchar(8000)
Declare @Cadena2	Varchar(8000)
Declare @Cadena3	Varchar(8000)

Declare @Cadena4	Varchar(8000)
Declare @Cadena5	Varchar(8000)
Declare @Cadena6	Varchar(8000)

Declare @Fecha		SmallDateTime
Declare @FechaI		SmallDateTime
Declare @FechaF		SmallDateTime
Declare @FI			SmallDateTime
Declare @FF			SmallDateTime
Declare @Contador 	Int
Declare @Contador1 	Int
Declare @Decimal	Decimal(18,4)
Declare @Periodo	Varchar(6)
Declare @InicioGeneral	DateTime

Set @InicioGeneral = GetDate()

SELECT  @FechaI =  MIN(Fecha) 
FROM         tCsClientesObservaciones

SELECT  @FechaF = FechaConsolidacion FROM         vCsFechaConsolidacion

Set @Periodo = dbo.fdufechaAtexto(@FechaF, 'AAAAMM')

Set @Fecha  = Cast(@Periodo + '01' as SmallDateTime) - 1

If @FechaI < @Fecha
Begin
	Set @FechaI = @Fecha
End

Set @FI = Cast(@Periodo + '01' as SmallDateTime) - 1
Set @FF = Cast(dbo.fduFechaAtexto(DateAdd(Month, 2, @FI), 'AAAAMM') + '01' As  SmallDateTime) - 1

SELECT   @FI = MIN(Fecha) 
FROM         tCsClientesObservaciones
WHERE     (Fecha >= @FI) AND (Fecha <= @FF)

SELECT   @FF = MAX(Fecha) FROM         tCsClientesObservaciones WHERE     (Fecha >= @FI) AND (Fecha <= @FF)

If @Dato <> 6 -- El dato representa codigo de usuario especifico y no ubicación.
Begin
	Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
End
Else
Begin
	Set @CUbicacion = '''' + @Ubicacion + ''''
End
Exec pGnlCalculaParametros 7, @Observacion, 	@CObservacion 	Out, 	@Observacion 	Out,  @OtroDato Out

CREATE TABLE #ResumenFechas (
				[Fecha] 	[smalldatetime] NOT NULL,
				[Activo] 	[Bit] 			NULL)

CREATE TABLE #ResumenOficinas (
	[CodOficina] [varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Oficina] [varchar] (30) COLLATE Modern_Spanish_CI_AI NULL ,
	[Inicio] [int] NOT NULL ,
	[Fin] [int] NOT NULL ,
	[Diferencia] [int] NULL ,
	[Porcentaje] [decimal](37, 19) NULL ,
	[PD] [int] NULL ,
	[PP] [int] NULL ,
	[PT] [int] NULL ) 

If @Dato In (1, 6) -- DETALLE DE OBSERVACIONES
Begin
	If @Dato = 1 Begin Set @Cadena5 = 'tCsClientesObservaciones.OOrigen		IN ('+ @CUbicacion +')'	End
	If @Dato = 6 Begin Set @Cadena5 = 'tCsClientesObservaciones.CodUsuario	IN ('+ @CUbicacion +')'	End
		
	Set @Cadena1 = 'SELECT * '
	Set @Cadena1 = @Cadena1 +  'FROM (SELECT tCsClientesObservaciones.Fecha, CodOficina = Cast(tClOficinas.CodOficina as Int), tClOficinas.NomOficina, tCsClClientesObservaciones.Observacion, '
	Set @Cadena1 = @Cadena1 +  'tCsClClientesObservaciones.Nombre, tCsClClientesObservaciones.Problema, tCsClClientesObservaciones.Solucion, '
	Set @Cadena1 = @Cadena1 +  'tCsPadronClientes.CodUsuario, tCsPadronClientes.Paterno, tCsPadronClientes.Materno, tCsPadronClientes.Nombres, '
	Set @Cadena1 = @Cadena1 +  'tCsClientesObservaciones.CodCuenta, tCsClientesObservaciones.CodPrestamo, tCsClientesObservaciones.Detalle, '
	Set @Cadena1 = @Cadena1 +  'tCsClientesObservaciones.Prioridad, 2 AS OtroDato, tCsClientesObservaciones.ROrigen, tCsClientesObservaciones.RAhorros, '
	Set @Cadena1 = @Cadena1 +  'tCsClientesObservaciones.RCreditos, tCsClientesObservaciones.Responsable, tCsPadronClientes_1.NombreCompleto AS RAgencia, tCsPadronClientes.fechaNacimiento, tCsPadronClientes.Fechaingreso '
	Set @Cadena1 = @Cadena1 +  'FROM tCsClientesObservaciones with(nolock) INNER JOIN '
	Set @Cadena1 = @Cadena1 +  '(SELECT CASE WHEN Contador <= 1 THEN FechaConsolidacion - 1 ELSE FechaConsolidacion END AS FechaConsolidacion FROM '
	Set @Cadena1 = @Cadena1 +  '(SELECT COUNT(*) AS Contador, vCsFechaConsolidacion.FechaConsolidacion FROM vCsFechaConsolidacion LEFT OUTER JOIN '
	Set @Cadena1 = @Cadena1 +  'tCsClientesObservaciones ON vCsFechaConsolidacion.FechaConsolidacion = tCsClientesObservaciones.Fecha GROUP BY '
	Set @Cadena1 = @Cadena1 +  'vCsFechaConsolidacion.FechaConsolidacion) Datos)vCsFechaConsolidacion ON tCsClientesObservaciones.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN '
	Set @Cadena1 = @Cadena1 +  'tCsClClientesObservaciones ON tCsClientesObservaciones.Observacion = tCsClClientesObservaciones.Observacion INNER JOIN '
	Set @Cadena1 = @Cadena1 +  'tCsPadronClientes with(nolock) ON tCsClientesObservaciones.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN '
	Set @Cadena1 = @Cadena1 +  'tClOficinas ON tCsClientesObservaciones.OOrigen = tClOficinas.CodOficina LEFT OUTER JOIN '
	Set @Cadena1 = @Cadena1 +  'tCsPadronClientes tCsPadronClientes_1 ON tClOficinas.CodUsACargo = tCsPadronClientes_1.CodUsuario '
	Set @Cadena1 = @Cadena1 +  'WHERE ('+ @Cadena5 +' AND tCsClientesObservaciones.Observacion IN ('+ @CObservacion +')) '
	
	If @Dato = 1 Begin Set @Cadena5 = 'tCsClientesObservaciones.OAhorros	IN ('+ @CUbicacion +')'	End
	If @Dato = 6 Begin Set @Cadena5 = 'tCsClientesObservaciones.CodUsuario	IN ('+ @CUbicacion +')'	End
		
	Set @Cadena2 = 'UNION '
	Set @Cadena2 = @Cadena2 +  'SELECT tCsClientesObservaciones.Fecha, CodOficina = Cast(tClOficinas.CodOficina as Int), tClOficinas.NomOficina, tCsClClientesObservaciones.Observacion, '
	Set @Cadena2 = @Cadena2 +  'tCsClClientesObservaciones.Nombre, tCsClClientesObservaciones.Problema, tCsClClientesObservaciones.Solucion, '
	Set @Cadena2 = @Cadena2 +  'tCsPadronClientes.CodUsuario, tCsPadronClientes.Paterno, tCsPadronClientes.Materno, tCsPadronClientes.Nombres, ' 
	Set @Cadena2 = @Cadena2 +  'tCsClientesObservaciones.CodCuenta, tCsClientesObservaciones.CodPrestamo, tCsClientesObservaciones.Detalle, '
	Set @Cadena2 = @Cadena2 +  'tCsClientesObservaciones.Prioridad, 2 AS OtroDato, tCsClientesObservaciones.ROrigen, tCsClientesObservaciones.RAhorros, '
 	Set @Cadena2 = @Cadena2 +  'tCsClientesObservaciones.RCreditos, tCsClientesObservaciones.Responsable, tCsPadronClientes_1.NombreCompleto AS RAgencia, tCsPadronClientes.fechaNacimiento, tCsPadronClientes.Fechaingreso '
	Set @Cadena2 = @Cadena2 +  'FROM tCsClientesObservaciones with(nolock) INNER JOIN '
	Set @Cadena2 = @Cadena2 +  '(SELECT CASE WHEN Contador <= 1 THEN FechaConsolidacion - 1 ELSE FechaConsolidacion END AS FechaConsolidacion FROM '
	Set @Cadena2 = @Cadena2 +  '(SELECT COUNT(*) AS Contador, vCsFechaConsolidacion.FechaConsolidacion FROM vCsFechaConsolidacion LEFT OUTER JOIN '
	Set @Cadena2 = @Cadena2 +  'tCsClientesObservaciones ON vCsFechaConsolidacion.FechaConsolidacion = tCsClientesObservaciones.Fecha GROUP BY '
	Set @Cadena2 = @Cadena2 +  'vCsFechaConsolidacion.FechaConsolidacion) Datos)vCsFechaConsolidacion ON tCsClientesObservaciones.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN '
	Set @Cadena2 = @Cadena2 +  'tCsClClientesObservaciones ON tCsClientesObservaciones.Observacion = tCsClClientesObservaciones.Observacion INNER JOIN '
	Set @Cadena2 = @Cadena2 +  'tCsPadronClientes with(nolock) ON tCsClientesObservaciones.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN '
	Set @Cadena2 = @Cadena2 +  'tClOficinas ON tCsClientesObservaciones.OAhorros = tClOficinas.CodOficina LEFT OUTER JOIN '
   	Set @Cadena2 = @Cadena2 +  'tCsPadronClientes tCsPadronClientes_1 ON tClOficinas.CodUsACargo = tCsPadronClientes_1.CodUsuario '
	Set @Cadena2 = @Cadena2 +  'WHERE ('+ @Cadena5 +' AND tCsClientesObservaciones.Observacion IN ('+ @CObservacion +')) '
	
	If @Dato = 1 Begin Set @Cadena5 = 'tCsClientesObservaciones.OCreditos	IN ('+ @CUbicacion +')'	End
	If @Dato = 6 Begin Set @Cadena5 = 'tCsClientesObservaciones.CodUsuario	IN ('+ @CUbicacion +')'	End
		
	Set @Cadena3 = 'UNION '
	Set @Cadena3 = @Cadena3 +  'SELECT tCsClientesObservaciones.Fecha, CodOficina = Cast(tClOficinas.CodOficina as Int), tClOficinas.NomOficina, tCsClClientesObservaciones.Observacion, '
	Set @Cadena3 = @Cadena3 +  'tCsClClientesObservaciones.Nombre, tCsClClientesObservaciones.Problema, tCsClClientesObservaciones.Solucion, '
	Set @Cadena3 = @Cadena3 +  'tCsPadronClientes.CodUsuario, tCsPadronClientes.Paterno, tCsPadronClientes.Materno, tCsPadronClientes.Nombres, ' 
	Set @Cadena3 = @Cadena3 +  'tCsClientesObservaciones.CodCuenta, tCsClientesObservaciones.CodPrestamo, tCsClientesObservaciones.Detalle, '
	Set @Cadena3 = @Cadena3 +  'tCsClientesObservaciones.Prioridad, 2 AS OtroDato, tCsClientesObservaciones.ROrigen, tCsClientesObservaciones.RAhorros, '
 	Set @Cadena3 = @Cadena3 +  'tCsClientesObservaciones.RCreditos, tCsClientesObservaciones.Responsable, tCsPadronClientes_1.NombreCompleto AS RAgencia, tCsPadronClientes.fechaNacimiento, tCsPadronClientes.Fechaingreso '
	Set @Cadena3 = @Cadena3 +  'FROM tCsClientesObservaciones with(nolock) INNER JOIN '
	Set @Cadena3 = @Cadena3 +  '(SELECT CASE WHEN Contador <= 1 THEN FechaConsolidacion - 1 ELSE FechaConsolidacion END AS FechaConsolidacion FROM '
	Set @Cadena3 = @Cadena3 +  '(SELECT COUNT(*) AS Contador, vCsFechaConsolidacion.FechaConsolidacion FROM vCsFechaConsolidacion LEFT OUTER JOIN '
	Set @Cadena3 = @Cadena3 +  'tCsClientesObservaciones ON vCsFechaConsolidacion.FechaConsolidacion = tCsClientesObservaciones.Fecha GROUP BY '
	Set @Cadena3 = @Cadena3 +  'vCsFechaConsolidacion.FechaConsolidacion) Datos)vCsFechaConsolidacion ON tCsClientesObservaciones.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN '
	Set @Cadena3 = @Cadena3 +  'tCsClClientesObservaciones ON tCsClientesObservaciones.Observacion = tCsClClientesObservaciones.Observacion INNER JOIN '
	Set @Cadena3 = @Cadena3 +  'tCsPadronClientes with(nolock) ON tCsClientesObservaciones.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN '
	Set @Cadena3 = @Cadena3 +  'tClOficinas ON tCsClientesObservaciones.OCreditos = tClOficinas.CodOficina LEFT OUTER JOIN '
  	Set @Cadena3 = @Cadena3 +  'tCsPadronClientes tCsPadronClientes_1 ON tClOficinas.CodUsACargo = tCsPadronClientes_1.CodUsuario '
	Set @Cadena3 = @Cadena3 +  'WHERE ('+ @Cadena5 +' AND tCsClientesObservaciones.Observacion IN ('+ @CObservacion +')) '
	Set @Cadena4 = ') Datos ORDER BY CodOficina, Observacion, Prioridad '
		
	If @Dato = 1 Begin Set @Cadena3 = @Cadena3 +  @Cadena4 	End
	If @Dato = 6 
	Begin
		Set @Cadena1 = @Cadena1 +  @Cadena4
		Set @Cadena2 = ''
		Set @Cadena3 = ''
	End
	
End
If @Dato = 2
Begin
	Set @Cadena1 = 'SELECT Datos.Fecha, Datos.Observacion, COUNT(*) AS Clientes, tCsClClientesObservaciones.Nombre ' 
	Set @Cadena1 = @Cadena1 + 'FROM (SELECT Fecha, CodUsuario, Observacion, OOrigen AS Oficina '
	Set @Cadena1 = @Cadena1 + 'FROM tCsClientesObservaciones with(nolock) '
	Set @Cadena1 = @Cadena1 + 'WHERE (OOrigen IS NOT NULL) '

	Set @Cadena2 = 'UNION '
	Set @Cadena2 = @Cadena2 + 'SELECT Fecha, Codusuario, Observacion, OAhorros '
	Set @Cadena2 = @Cadena2 + 'FROM tCsClientesObservaciones with(nolock) '
	Set @Cadena2 = @Cadena2 + 'WHERE (OAhorros IS NOT NULL) '

	Set @Cadena3 = 'UNION '
	Set @Cadena3 = @Cadena3 + 'SELECT Fecha, Codusuario, Observacion, OCreditos '
	Set @Cadena3 = @Cadena3 + 'FROM tCsClientesObservaciones with(nolock) '
	Set @Cadena3 = @Cadena3 + 'WHERE (OCreditos IS NOT NULL))  Datos INNER JOIN '
	Set @Cadena3 = @Cadena3 +  '(SELECT CASE WHEN Contador <= 1 THEN FechaConsolidacion - 1 ELSE FechaConsolidacion END AS FechaConsolidacion FROM '
	Set @Cadena3 = @Cadena3 +  '(SELECT COUNT(*) AS Contador, vCsFechaConsolidacion.FechaConsolidacion FROM vCsFechaConsolidacion LEFT OUTER JOIN '
	Set @Cadena3 = @Cadena3 +  'tCsClientesObservaciones ON vCsFechaConsolidacion.FechaConsolidacion = tCsClientesObservaciones.Fecha GROUP BY '
	Set @Cadena3 = @Cadena3 +  'vCsFechaConsolidacion.FechaConsolidacion) Datos)vCsFechaConsolidacion ON Datos.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN '
	Set @Cadena3 = @Cadena3 + 'tCsClClientesObservaciones ON Datos.Observacion COLLATE Modern_Spanish_CI_AI = tCsClClientesObservaciones.Observacion '
	Set @Cadena3 = @Cadena3 + 'WHERE (Datos.Oficina IN ('+ @CUbicacion +') AND Datos.Observacion IN ('+ @CObservacion +')) '
	Set @Cadena3 = @Cadena3 + 'GROUP BY Datos.Fecha, Datos.Observacion, tCsClClientesObservaciones.Nombre '
	Set @Cadena3 = @Cadena3 + 'ORDER BY Datos.Fecha '
End
If @Dato = 3
Begin
	Insert Into #ResumenFechas 
	SELECT DISTINCT Fecha, Activo = 1
	FROM         tCsClientesObservaciones
	WHERE     (Fecha >= @FechaI) AND (Fecha <= @FechaF)
	
	Select @Contador = Count(*) From (Select Distinct Fecha From #ResumenFechas)Datos

	If @Contador > 26
	Begin
		Update #ResumenFechas
		Set Activo = 0
		
		Set @Decimal 	= Cast(@Contador as Decimal(18,4)) / 26.0000
		Set @Contador1 	= 1
		Set @Contador 	= 1
	
		Declare curFragmento1 Cursor For 
			Select Distinct Fecha
			From #ResumenFechas		
		Open curFragmento1
		Fetch Next From curFragmento1 Into @Fecha
		While @@Fetch_Status = 0
		Begin 
			If @Fecha = @FechaI or @Fecha = @FechaF
			Begin
				Update #ResumenFechas
				Set Activo = 1
				Where Fecha = @Fecha
			End		
			If @Contador1 = Round(@Decimal * @Contador, 0)
			Begin
				Update #ResumenFechas
				Set Activo = 1
				Where Fecha = @Fecha
				Set @Contador = @Contador + 1
			End
			Set @Contador1 = @Contador1 + 1
		Fetch Next From curFragmento1 Into @Fecha
		End 
		Close 		curFragmento1
		Deallocate 	curFragmento1
	
		Delete From #ResumenFechas where Activo = 0
	End	
	
	Set @Cadena1 = 'SELECT Fecha, COUNT(*) AS Observaciones ' 
	Set @Cadena1 = @Cadena1 + 'FROM (SELECT tCsClientesObservaciones.Fecha, tCsClientesObservaciones.CodUsuario, tCsClientesObservaciones.Observacion, '
	Set @Cadena1 = @Cadena1 + 'tCsClientesObservaciones.OOrigen AS Oficina '
	Set @Cadena1 = @Cadena1 + 'FROM tCsClientesObservaciones with(nolock) INNER JOIN '
	Set @Cadena1 = @Cadena1 + '#ResumenFechas ON ' 
	Set @Cadena1 = @Cadena1 + 'tCsClientesObservaciones.Fecha = #ResumenFechas.Fecha '
	Set @Cadena1 = @Cadena1 + 'WHERE (tCsClientesObservaciones.OOrigen IS NOT NULL) '

	Set @Cadena2 = 'UNION '
	Set @Cadena2 = @Cadena2 + 'SELECT tCsClientesObservaciones.Fecha, tCsClientesObservaciones.CodUsuario, tCsClientesObservaciones.Observacion, '
	Set @Cadena2 = @Cadena2 + 'tCsClientesObservaciones.OAhorros AS Oficina '
	Set @Cadena2 = @Cadena2 + 'FROM tCsClientesObservaciones with(nolock) INNER JOIN '
	Set @Cadena2 = @Cadena2 + '#ResumenFechas ON ' 
	Set @Cadena2 = @Cadena2 + 'tCsClientesObservaciones.Fecha = #ResumenFechas.Fecha '
	Set @Cadena2 = @Cadena2 + 'WHERE (tCsClientesObservaciones.OAhorros IS NOT NULL) '

	Set @Cadena3 = 'UNION '
	Set @Cadena3 = @Cadena3 + 'SELECT tCsClientesObservaciones.Fecha, tCsClientesObservaciones.CodUsuario, tCsClientesObservaciones.Observacion, '
	Set @Cadena3 = @Cadena3 + 'tCsClientesObservaciones.OCreditos AS Oficina '
	Set @Cadena3 = @Cadena3 + 'FROM tCsClientesObservaciones with(nolock) INNER JOIN '
	Set @Cadena3 = @Cadena3 + '#ResumenFechas ON ' 
	Set @Cadena3 = @Cadena3 + 'tCsClientesObservaciones.Fecha = #ResumenFechas.Fecha '
	Set @Cadena3 = @Cadena3 + 'WHERE (tCsClientesObservaciones.OCreditos IS NOT NULL)) Datos '
	Set @Cadena3 = @Cadena3 + 'WHERE (Oficina IN ('+ @CUbicacion +') AND Datos.Observacion IN ('+ @CObservacion +')) '
	Set @Cadena3 = @Cadena3 + 'GROUP BY Fecha '
	Set @Cadena3 = @Cadena3 + 'ORDER BY Fecha '	
End
If @Dato = 4
Begin
	Declare @Cadena 	Varchar(8000)
	Declare @CadenaI 	Varchar(8000)
	Declare @CadenaF 	Varchar(8000)
	Declare @CodOficina	Varchar(4)
		
	Declare @Criterio 	Varchar(2)
	Declare @Campo	Varchar(50)
	
	Declare @PC		Varchar(5)
	Declare @PD		Varchar(5)
	Declare @PA		Varchar(5)
	
	Declare @itrContador	Int	

	Set @itrContador = 0

	Set @itrContador = @itrContador + 1 --  Aprox: 1
	Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
	Set @InicioGeneral = Getdate()

	Set @Cadena1 = 'Delete From tCsClientesCriterio Where dbo.fduFechaATexto(Inicio, ''AAAAMMDD'') = ''' + dbo.fduFechaATexto(@FI, 'AAAAMMDD') + ''' And CodOficina in ('+ @CUbicacion+ ')'
	Exec (@Cadena1)
	
	Set @itrContador = @itrContador + 1 --  Aprox: 2
	Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
	Set @InicioGeneral = Getdate()
												
	CREATE TABLE #SSSSSSSSS(
	[Observacion] [varchar](2) NOT NULL,
	[CodUsuario] [varchar](15) NOT NULL,
	[Antiguedad] [int] NULL	) 	
	
	CREATE TABLE #SS(
	[Observacion] [varchar](2) NOT NULL,
	[CodUsuario] [varchar](15) NOT NULL,
	[Antiguedad] [int] NULL	) 											
																				
	Set @Cadena1 = 'Insert Into #SSSSSSSSS SELECT Observacion, CodUsuario, COUNT(*) AS Antiguedad FROM tCsClientesObservaciones with(nolock) '
	Set @Cadena1 = @Cadena1 + 'WHERE (dbo.fduFechaATexto(Fecha, ''AAAAMMDD'') <= ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''') '
	Set @Cadena1 = @Cadena1 + 'And (OORigen in ('+ @CUbicacion+ ') Or OAhorros in ('+ @CUbicacion+ ') Or OCreditos in ('+ @CUbicacion + ')) '
	Set @Cadena1 = @Cadena1 + 'GROUP BY Observacion, CodUsuario'
	
	Print @Cadena1
	Exec (@Cadena1)
	
	Set @itrContador = @itrContador + 1 --  Aprox: 3
	Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
	Set @InicioGeneral = Getdate()	

	Set @Cadena1 = 'Insert Into #SS SELECT DISTINCT SSSSSSSSS.Observacion, SSSSSSSSS.CodUsuario, SSSSSSSSS.Antiguedad '
	Set @Cadena1 = @Cadena1 + 'FROM #SSSSSSSSS SSSSSSSSS INNER JOIN tCsClientesObservaciones with(nolock) ON SSSSSSSSS.Observacion '
	Set @Cadena1 = @Cadena1 + '= tCsClientesObservaciones.Observacion AND SSSSSSSSS.CodUsuario = '
	Set @Cadena1 = @Cadena1 + 'tCsClientesObservaciones.CodUsuario WHERE (dbo.fduFechaATexto(tCsClientesObservaciones.Fecha, ''AAAAMMDD'') = ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''') '
	Set @Cadena1 = @Cadena1 + 'And (OORigen in ('+ @CUbicacion +') Or OAhorros in ('+ @CUbicacion+ ') Or OCreditos in ('+ @CUbicacion + ')) '

	Print @Cadena1
	Exec (@Cadena1)

	Set @itrContador = @itrContador + 1 --  Aprox: 4
	Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
	Set @InicioGeneral = Getdate()	

	Declare curFragmento Cursor For 
		SELECT    Criterio, Campo, PCantidadFinal, PDiferencia, PAvance
		FROM      tCsClClientesCriterio
		WHERE     (Activo = 1)
	Open curFragmento
	Fetch Next From curFragmento Into @Criterio, @Campo, @PC, @PD, @PA
	While @@Fetch_Status = 0
	Begin 
		Set @itrContador = @itrContador + 1 --  Aprox: 5
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()
		Print '-----------------'
		Print @Criterio
		Print @Campo
		Print @PC
		Print @PD
		Print @PA
		Print '-----------------'	

		Set @Cadena = 'Insert Into tCsClientesCriterio (Criterio, CodOficina, Inicio, Fin, PC, PD, PA) '
		Set @Cadena = @Cadena +  'SELECT Criterio = '''+ @Criterio +''' ,CodOficina, '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''' AS Inicio, '
		Set @Cadena = @Cadena +  ''''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''' AS Fin, PC = '''+ @PC +''' , PD = '''+ @PD +''' , PA = '''+ @PA +''' '
		Set @Cadena = @Cadena +  'FROM tClOficinas '
		Set @Cadena = @Cadena +  'WHERE (CodOficina IN ('+ @CUbicacion +')) '
		Print @Cadena
		Exec(@Cadena)
		
		Set @itrContador = @itrContador + 1 --  Aprox: 6
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Set @Cadena = 'Update tCsClientesCriterio Set Icantidad = 0, FCantidad = 0 Where Criterio = ''' + @Criterio + ''' '
		Set @Cadena = @Cadena +  'And dbo.fduFechaATexto(Inicio, ''AAAAMMDD'') = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''' '
		Set @Cadena = @Cadena +  'And CodOficina in (' + @CUbicacion + ')'
		Print @Cadena
		Exec(@Cadena)

		Set @itrContador = @itrContador + 1 --  Aprox: 7
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()
		
		Set @CadenaI = 'SELECT Datos.Fecha, Datos.CodOficina, SUM(Datos.Observaciones) AS Observaciones, SUM(Datos.Antiguedad) / CAST(SUM(Datos.Observaciones) '
		Set @CadenaI = @CadenaI + 'AS decimal(18, 4)) AS Antiguedad, SUM(Datos.Prioridad) / CAST(SUM(Datos.Observaciones) AS decimal(18, 4)) AS Prioridad, Tipo.Tipos '
		Set @CadenaI = @CadenaI + 'FROM (SELECT Fecha, CodOficina, SUM(Cliente) AS Observaciones, Antiguedad * SUM(Cliente) AS Antiguedad, Prioridad * SUM(Cliente) AS Prioridad '
		Set @CadenaI = @CadenaI + 'FROM (SELECT Origen.Fecha, Origen.CodUsuario, Origen.Observacion, Origen.CodOficina, Origen.Cliente, Origen.Prioridad, '
		Set @CadenaI = @CadenaI + 'Datos.Antiguedad '
		Set @CadenaI = @CadenaI + 'FROM (SELECT Fecha, CodUsuario, Observacion, OOrigen AS CodOficina, 1 AS Cliente, Prioridad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND (OOrigen IS NOT NULL) AND (Observacion IN ('+ @CObservacion +')) AND (OOrigen IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT Fecha, CodUsuario, Observacion, OAhorros AS CodOficina, 1 AS Cliente, Prioridad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND (OAhorros IS NOT NULL) AND (Observacion IN ('+ @CObservacion +')) AND (OAhorros IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT Fecha, CodUsuario, Observacion, OCreditos AS CodOficina, 1 AS Cliente, Prioridad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND (OCreditos IS NOT NULL) AND (Observacion IN ('+ @CObservacion +')) AND (OCreditos IN ('+ @CUbicacion +'))) '
		Set @CadenaI = @CadenaI + 'Origen INNER JOIN '
		Set @CadenaI = @CadenaI + '(SELECT Observacion, CodUsuario, COUNT(*) AS Antiguedad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha <= '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') '
		Set @CadenaI = @CadenaI + 'GROUP BY Observacion, CodUsuario) Datos ON Origen.Observacion = Datos.Observacion AND '
		Set @CadenaI = @CadenaI + 'Origen.CodUsuario = Datos.CodUsuario) Datos '
		Set @CadenaI = @CadenaI + 'GROUP BY Fecha, CodOficina, Antiguedad, Prioridad) Datos INNER JOIN '
		Set @CadenaI = @CadenaI + '(SELECT CodOficina, COUNT(*) AS Tipos '
		Set @CadenaI = @CadenaI + 'FROM (SELECT DISTINCT OOrigen AS CodOficina, Observacion '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND Oorigen IS NOT NULL AND (Observacion IN ('+ @CObservacion +')) AND (OOrigen IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT DISTINCT Oahorros, Observacion '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND Oahorros IS NOT NULL AND (Observacion IN ('+ @CObservacion +')) AND (OAhorros IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT DISTINCT OCreditos, Observacion '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') AND OCreditos IS NOT NULL AND (Observacion IN ('+ @CObservacion +')) AND (OCreditos IN ('+ @CUbicacion +'))) '
		Set @CadenaI = @CadenaI + 'Datos '
		Set @CadenaI = @CadenaI + 'GROUP BY CodOficina) Tipo ON Datos.CodOficina = Tipo.CodOficina '
		Set @CadenaI = @CadenaI + 'GROUP BY Datos.Fecha, Datos.CodOficina, Tipo.Tipos '
		
		Set @Cadena = 'UPDATE tCsClientesCriterio '
		Set @Cadena = @Cadena + 'SET ICantidad = '+ @Campo +' '
		Set @Cadena = @Cadena + 'FROM tCsClientesCriterio INNER JOIN '
		Set @Cadena = @Cadena + '('+ @CadenaI +') Datos ON tCsClientesCriterio.Inicio = Datos.Fecha AND '
		Set @Cadena = @Cadena + 'tCsClientesCriterio.CodOficina = Datos.CodOficina COLLATE Modern_Spanish_CI_AI WHERE Criterio = ''' + @Criterio +''' AND (Inicio = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') And tCsClientesCriterio.CodOficina in ('+ @CUbicacion +')'
		
		Print @Cadena
		Exec(@Cadena)
		
		Set @itrContador = @itrContador + 1 --  Aprox: 8
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Set @CadenaI = 'SELECT Datos.Fecha, Datos.CodOficina, SUM(Datos.Observaciones) AS Observaciones, SUM(Datos.Antiguedad) / CAST(SUM(Datos.Observaciones) '
		Set @CadenaI = @CadenaI + 'AS decimal(18, 4)) AS Antiguedad, SUM(Datos.Prioridad) / CAST(SUM(Datos.Observaciones) AS decimal(18, 4)) AS Prioridad, Tipo.Tipos '
		Set @CadenaI = @CadenaI + 'FROM (SELECT Fecha, CodOficina, SUM(Cliente) AS Observaciones, Antiguedad * SUM(Cliente) AS Antiguedad, Prioridad * SUM(Cliente) AS Prioridad '
		Set @CadenaI = @CadenaI + 'FROM (SELECT Origen.Fecha, Origen.CodUsuario, Origen.Observacion, Origen.CodOficina, Origen.Cliente, Origen.Prioridad, '
		Set @CadenaI = @CadenaI + 'Datos.Antiguedad '
		Set @CadenaI = @CadenaI + 'FROM (SELECT Fecha, CodUsuario, Observacion, OOrigen AS CodOficina, 1 AS Cliente, Prioridad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND (OOrigen IS NOT NULL) AND (Observacion IN ('+ @CObservacion +')) AND (OOrigen IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT Fecha, CodUsuario, Observacion, OAhorros AS CodOficina, 1 AS Cliente, Prioridad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND (OAhorros IS NOT NULL) AND (Observacion IN ('+ @CObservacion +')) AND (OAhorros IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT Fecha, CodUsuario, Observacion, OCreditos AS CodOficina, 1 AS Cliente, Prioridad '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND (OCreditos IS NOT NULL) AND (Observacion IN ('+ @CObservacion +')) AND (OCreditos IN ('+ @CUbicacion +'))) '
		Set @CadenaI = @CadenaI + 'Origen INNER JOIN '
		Set @CadenaI = @CadenaI + '(SELECT * FROM #SS with(nolock)) Datos ON Origen.Observacion = Datos.Observacion AND '
		Set @CadenaI = @CadenaI + 'Origen.CodUsuario = Datos.CodUsuario) Datos '
		Set @CadenaI = @CadenaI + 'GROUP BY Fecha, CodOficina, Antiguedad, Prioridad) Datos INNER JOIN '
		Set @CadenaI = @CadenaI + '(SELECT CodOficina, COUNT(*) AS Tipos '
		Set @CadenaI = @CadenaI + 'FROM (SELECT DISTINCT OOrigen AS CodOficina, Observacion '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND Oorigen IS NOT NULL AND (Observacion IN ('+ @CObservacion +')) AND (OOrigen IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT DISTINCT Oahorros, Observacion '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND Oahorros IS NOT NULL AND (Observacion IN ('+ @CObservacion +')) AND (OAhorros IN ('+ @CUbicacion +')) '
		Set @CadenaI = @CadenaI + 'UNION '
		Set @CadenaI = @CadenaI + 'SELECT DISTINCT OCreditos, Observacion '
		Set @CadenaI = @CadenaI + 'FROM tCsClientesObservaciones with(nolock) '
		Set @CadenaI = @CadenaI + 'WHERE (Fecha = '''+ dbo.fduFechaAtexto(@FF, 'AAAAMMDD') +''') AND OCreditos IS NOT NULL AND (Observacion IN ('+ @CObservacion +')) AND (OCreditos IN ('+ @CUbicacion +'))) '
		Set @CadenaI = @CadenaI + 'Datos '
		Set @CadenaI = @CadenaI + 'GROUP BY CodOficina) Tipo ON Datos.CodOficina = Tipo.CodOficina '
		Set @CadenaI = @CadenaI + 'GROUP BY Datos.Fecha, Datos.CodOficina, Tipo.Tipos '
		
		Set @Cadena = 'UPDATE tCsClientesCriterio '
		Set @Cadena = @Cadena + 'SET FCantidad = '+ @Campo +' '
		Set @Cadena = @Cadena + 'FROM tCsClientesCriterio INNER JOIN '
		Set @Cadena = @Cadena + '('+ @CadenaI +') Datos ON tCsClientesCriterio.Fin = Datos.Fecha AND '
		Set @Cadena = @Cadena + 'tCsClientesCriterio.CodOficina = Datos.CodOficina COLLATE Modern_Spanish_CI_AI WHERE Criterio = ''' + @Criterio +''' AND (Inicio = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') And tCsClientesCriterio.CodOficina in ('+ @CUbicacion +')'
		
		Print @Cadena
		Exec(@Cadena)
	
		Set @itrContador = @itrContador + 1 --  Aprox: 9
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()
		
	Fetch Next From curFragmento Into @Criterio, @Campo, @PC, @PD, @PA
	End 
	Close 		curFragmento
	Deallocate 	curFragmento	
	
	Set @Cadena = 'UPDATE tCsClientesCriterio SET Diferencia = FCantidad - ICantidad Where Inicio = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''' And CodOficina in ('+ @CUbicacion +')'
	Print @Cadena
	Exec(@Cadena)
	
	Set @Cadena = 'UPDATE tCsClientesCriterio SET Porcentaje = Diferencia / CASE WHEN ICantidad = 0 THEN 1 ELSE icantidad END * 100 Where Inicio = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''' And CodOficina in ('+ @CUbicacion +')'
	Print @Cadena
	Exec(@Cadena)
	
	Set @itrContador = @itrContador + 1 --  Aprox: 10
	Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
	Set @InicioGeneral = Getdate()

	Create Table #SSS
	( CodOficina Varchar(4))
	
	Set @Cadena = @Cadena +  'Insert Into #SSS SELECT CodOficina '
	Set @Cadena = @Cadena +  'FROM tClOficinas '
	Set @Cadena = @Cadena +  'WHERE (CodOficina IN ('+ @CUbicacion +')) '
	Print @Cadena
	Exec(@Cadena)

	Declare curFragmento1 Cursor For 
		Select CodOficina, Criterio, PC, PD, PA
		From tCsClientesCriterio
		Where Inicio = @FI And CodOficina in (Select CodOficina From #SSS)
	Open curFragmento1
	Fetch Next From curFragmento1 Into @CodOficina, @Criterio, @PC, @PD, @PA
	While @@Fetch_Status = 0
	Begin 
		Set @itrContador = @itrContador + 1 --  Aprox: 11
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()
		
		If Substring(Rtrim(Ltrim(@PC)), 1, 1) = '-'
		Begin	
			UPDATE    tCsClientesCriterio
			SET              PCantidad = Puntaje
			FROM         (SELECT     Datos.CodOficina, COUNT(*) + 1 AS Puntaje
			                       FROM          (SELECT     CodOficina, FCantidad as Dato
			                                               FROM          tCsClientesCriterio
			                                               WHERE      (CodOficina = @CodOficina) AND (Criterio = @Criterio) AND Inicio = @FI) Datos INNER JOIN
			                                              tCsClientesCriterio ON Datos.Dato < tCsClientesCriterio.FCantidad
						Where (Criterio = @Criterio) AND Inicio = @FI
			                       GROUP BY Datos.CodOficina) Datos INNER JOIN
			                      tCsClientesCriterio ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesCriterio.CodOficina
			Where (Criterio = @Criterio) And Inicio = @FI	
		End
		If Substring(Rtrim(Ltrim(@PC)), 1, 1) = '+'
		Begin	
			UPDATE    tCsClientesCriterio
			SET              PCantidad = Puntaje
			FROM         (SELECT     Datos.CodOficina, COUNT(*) + 1 AS Puntaje
			                       FROM          (SELECT     CodOficina, FCantidad as Dato
			                                               FROM          tCsClientesCriterio
			                                               WHERE      (CodOficina = @CodOficina) AND (Criterio = @Criterio) AND Inicio = @FI) Datos INNER JOIN
			                                              tCsClientesCriterio ON Datos.Dato > tCsClientesCriterio.FCantidad
						Where (Criterio = @Criterio) AND Inicio = @FI
			                       GROUP BY Datos.CodOficina) Datos INNER JOIN
			                      tCsClientesCriterio ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesCriterio.CodOficina
			Where (Criterio = @Criterio) And Inicio = @FI
		End
	
		If Substring(Rtrim(Ltrim(@PD)), 1, 1) = '-'
		Begin		
			UPDATE    tCsClientesCriterio
			SET              PDiferencia = Puntaje
			FROM         (SELECT     Datos.CodOficina, COUNT(*) + 1 AS Puntaje
			                       FROM          (SELECT     CodOficina, Diferencia as Dato
			                                               FROM          tCsClientesCriterio
			                                               WHERE      (CodOficina = @CodOficina) AND (Criterio = @Criterio) AND Inicio = @FI) Datos INNER JOIN
			                                              tCsClientesCriterio ON Datos.Dato < tCsClientesCriterio.Diferencia
						Where (Criterio = @Criterio) AND Inicio = @FI
			                       GROUP BY Datos.CodOficina) Datos INNER JOIN
			                      tCsClientesCriterio ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesCriterio.CodOficina
			Where (Criterio = @Criterio) And Inicio = @FI	
		End
	
		If Substring(Rtrim(Ltrim(@PD)), 1, 1) = '+'
		Begin		
			UPDATE    tCsClientesCriterio
			SET              PDiferencia = Puntaje
			FROM         (SELECT     Datos.CodOficina, COUNT(*) + 1 AS Puntaje
			                       FROM          (SELECT     CodOficina, Diferencia as Dato
			                                               FROM          tCsClientesCriterio
			                                               WHERE      (CodOficina = @CodOficina) AND (Criterio = @Criterio) AND Inicio = @FI) Datos INNER JOIN
			                                              tCsClientesCriterio ON Datos.Dato > tCsClientesCriterio.Diferencia
						Where (Criterio = @Criterio) AND Inicio = @FI
			                       GROUP BY Datos.CodOficina) Datos INNER JOIN
			                      tCsClientesCriterio ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesCriterio.CodOficina
			Where (Criterio = @Criterio) AND Inicio = @FI
		End
		
		If Substring(Rtrim(Ltrim(@PA)), 1, 1) = '-'
		Begin
			UPDATE    tCsClientesCriterio
			SET              PPorcentaje = Puntaje
			FROM         (SELECT     Datos.CodOficina, COUNT(*) + 1 AS Puntaje
			                       FROM          (SELECT     CodOficina, Porcentaje as Dato
			                                               FROM          tCsClientesCriterio
			                                               WHERE      (CodOficina = @CodOficina) AND (Criterio = @Criterio) AND Inicio = @FI) Datos INNER JOIN
			                                              tCsClientesCriterio ON Datos.Dato < tCsClientesCriterio.Porcentaje
						Where (Criterio = @Criterio) AND Inicio = @FI
			                       GROUP BY Datos.CodOficina) Datos INNER JOIN
			                      tCsClientesCriterio ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesCriterio.CodOficina
			Where (Criterio = @Criterio) AND Inicio = @FI
		End 
		If Substring(Rtrim(Ltrim(@PA)), 1, 1) = '+'
		Begin
			UPDATE    tCsClientesCriterio
			SET              PPorcentaje = Puntaje
			FROM         (SELECT     Datos.CodOficina, COUNT(*) + 1 AS Puntaje
			                       FROM          (SELECT     CodOficina, Porcentaje as Dato
			                                               FROM          tCsClientesCriterio
			                                               WHERE      (CodOficina = @CodOficina) AND (Criterio = @Criterio) AND Inicio = @FI) Datos INNER JOIN
			                                              tCsClientesCriterio ON Datos.Dato > tCsClientesCriterio.Porcentaje
						Where (Criterio = @Criterio) AND Inicio = @FI
			                       GROUP BY Datos.CodOficina) Datos INNER JOIN
			                      tCsClientesCriterio ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesCriterio.CodOficina
			Where (Criterio = @Criterio) AND Inicio = @FI
		End 
	
		Set @itrContador = @itrContador + 1 --  Aprox: 11
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Update tCsClientesCriterio
		Set PCantidad = 1
		Where PCantidad Is Null and CodOficina = @CodOficina And Criterio = @Criterio AND Inicio = @FI
	
		Set @itrContador = @itrContador + 1 --  Aprox: 12
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Update tCsClientesCriterio
		Set PDiferencia = 1
		Where PDiferencia Is Null and CodOficina = @CodOficina And Criterio = @Criterio AND Inicio = @FI
	
		Set @itrContador = @itrContador + 1 --  Aprox: 13
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Update tCsClientesCriterio
		Set PPorcentaje = 1
		Where PPorcentaje Is Null and CodOficina = @CodOficina And Criterio = @Criterio AND Inicio = @FI
	
		Set @itrContador = @itrContador + 1 --  Aprox: 14
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Set @Cadena = 'UPDATE tCsClientesCriterio Set PCP = PCantidad * '+ RTrim(Ltrim(Substring(@PC, 2, 5))) +' WHERE CodOficina = ''' + @CodOficina  + ''' And Criterio = ''' + @Criterio  + '''' 
		Print @Cadena
		Exec(@Cadena)	
	
		Set @itrContador = @itrContador + 1 --  Aprox: 15
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Set @Cadena = 'UPDATE tCsClientesCriterio Set PDP = PDiferencia * '+ RTrim(Ltrim(Substring(@PD, 2, 5))) +' WHERE CodOficina = ''' + @CodOficina  + ''' And Criterio = ''' + @Criterio + '''' 
		Print @Cadena
		Exec(@Cadena)
	
		Set @itrContador = @itrContador + 1 --  Aprox: 16
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Set @Cadena = 'UPDATE tCsClientesCriterio Set PAP = PPorcentaje * '+ RTrim(Ltrim(Substring(@PA, 2, 5))) +' WHERE CodOficina = ''' + @CodOficina  + ''' And Criterio = ''' + @Criterio + '''' 
		Print @Cadena
		Exec(@Cadena)
	
		Set @itrContador = @itrContador + 1 --  Aprox: 17
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

		Update tCsClientesCriterio
		Set Final = (PCP + PDP + PAP)/ (Cast(Substring(@PC, 2, 5) as Decimal(10,4)) + Cast(Substring(@PD, 2, 5) as Decimal(10,4)) + Cast(Substring(@PA, 2, 5) as Decimal(10,4)))
		Where CodOficina = @CodOficina And Criterio = @Criterio AND Inicio = @FI

		Set @itrContador = @itrContador + 1 --  Aprox: 18
		Print 'Cotador : ' + Cast(@itrContador as Varchar(10)) + '  '  + Cast(getdate() as Varchar(100)) + ' Tiempo Ejecución: ' + dbo.fduformatoHora(DateDiff(Second, @InicioGeneral, GetDate()))	
		Set @InicioGeneral = Getdate()

	Fetch Next From curFragmento1 Into @CodOficina, @Criterio, @PC, @PD, @PA
	End 
	Close 		curFragmento1
	Deallocate 	curFragmento1

	Set @Cadena1 		= 'Select ''Proceso Concluido'''
	Set @Cadena2 		= ' As Proceso' 
	Set @Cadena3		= ''	
	
	Drop Table #SS
	Drop Table #SSS
	Drop Table #SSSSSSSSS	
End


If @Dato = 5
Begin
	Set @Cadena1 = 'SELECT  Inicio, Fin,   CodOficina, NomOficina, Puntaje '
	Set @Cadena1 = @Cadena1 + 'FROM (SELECT   tCsClientesCriterio.Inicio, tCsClientesCriterio.Fin,  tCsClientesCriterio.CodOficina, (SUM(Final * tCsClClientesCriterio.Ponderado) / SUM(tCsClClientesCriterio.Ponderado)) '
	Set @Cadena1 = @Cadena1 + '* 10 / Datos.Factor AS Puntaje, tClOficinas.NomOficina '
	Set @Cadena1 = @Cadena1 + 'FROM  tCsClientesCriterio INNER JOIN '
	
	Set @Cadena2 = 'tCsClClientesCriterio ON tCsClientesCriterio.Criterio = tCsClClientesCriterio.Criterio INNER JOIN '
	Set @Cadena2 = @Cadena2 + 'tClOficinas ON tCsClientesCriterio.CodOficina = tClOficinas.CodOficina CROSS JOIN '
	Set @Cadena2 = @Cadena2 + '(SELECT COUNT(*) AS Factor '
	Set @Cadena2 = @Cadena2 + 'FROM (SELECT DISTINCT CodOficina '
	
	Set @Cadena3 = 'FROM tCsClientesCriterio '
	--Set @Cadena3 = @Cadena3 + 'Where (Inicio = '''+ dbo.fduFechaAtexto(@FI, 'AAAAMMDD') +''') '
	Set @Cadena3 = @Cadena3 + ')Datos ) Datos GROUP BY tCsClientesCriterio.Inicio, tCsClientesCriterio.Fin, tCsClientesCriterio.CodOficina, tClOficinas.NomOficina, Datos.Factor) Datos '
	Set @Cadena3 = @Cadena3 + 'Where (Inicio >= '''+ dbo.fduFechaAtexto(DateAdd(Year, -1, @FechaF), 'AAAAMMDD') +''')  AND  (Inicio < '''+ dbo.fduFechaAtexto(@FechaF, 'AAAAMMDD') +''') '
	Set @Cadena3 = @Cadena3 + 'ORDER BY Inicio, Puntaje DESC '
End

Print @Cadena1
Print @Cadena2
Print @Cadena3
Exec (@Cadena1 +  @Cadena2 + @Cadena3)
DROP TABLE #ResumenFechas
DROP TABLE #ResumenOficinas
GO