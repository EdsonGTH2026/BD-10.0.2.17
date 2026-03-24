SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pGnlValidacionDatos] 
@Tip Int -- 0: Resumen, Si pone número sale el detalle de la observación.
As
Declare @Cadena 	Varchar(8000)
Declare @Observacion 	Varchar(8000)
Declare @Tipo		Varchar(100)
Declare @Fecha		SmallDateTime
Declare @Temporal	Varchar(8000)

SELECT   @Fecha =  FechaConsolidacion
FROM         vCsFechaConsolidacion

---Set @Fecha = '20071122'

Create Table #Observaciones 
(	
Observacion	Varchar(100),
Errores		Int
)

-------------------------------------------------------------
Set @Tipo = '01: Asesores de Cartera sin relación con el Padrón de Clientes'

Set @Observacion = 'SELECT DISTINCT Datos.CodAsesor '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes RIGHT OUTER JOIN '
Set @Observacion = @Observacion + '(SELECT Datos.CodAsesor, tCsPadronAsesores.NomAsesor '
Set @Observacion = @Observacion + 'FROM (SELECT DISTINCT CodAsesor '
Set @Observacion = @Observacion + 'FROM tCsCartera) Datos LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsPadronAsesores ON Datos.CodAsesor COLLATE Modern_Spanish_CI_AI = tCsPadronAsesores.CodAsesor '
Set @Observacion = @Observacion + 'WHERE (nomasesor IS NULL)) Datos ON tCsPadronClientes.CodUsuario = Datos.CodAsesor COLLATE Modern_Spanish_CI_AI '
Set @Observacion = @Observacion + 'WHERE (tCsPadronClientes.NombreCompleto IS NULL) '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-------------------------------------------------------------
Set @Tipo = '02: Clientes de Cartera sin relación con el Padrón de Clientes'

Set @Observacion = 'SELECT Datos.CodUsuario '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes RIGHT OUTER JOIN '
Set @Observacion = @Observacion + '(SELECT DISTINCT CodUsuario '
Set @Observacion = @Observacion + 'FROM tCsCartera) Datos ON tCsPadronClientes.CodUsuario = Datos.CodUsuario COLLATE Modern_Spanish_CI_AI '
Set @Observacion = @Observacion + 'WHERE (tCsPadronClientes.NombreCompleto IS NULL) '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-------------------------------------------------------------
Set @Tipo = '03: Clientes con nombres duplicados'

Set @Observacion = 'SELECT Maestro.CodUsuario, CAST(Datos.NroVeces AS varchar(5)) + '' Veces el nombre: '' + Datos.Nombre AS Observacion, '
Set @Observacion = @Observacion + ''''''''' + RTRIM(LTRIM(Maestro.CodUsuario)) + '''''','' AS Dato1, ''WHERE (NombreCompleto = '''''' + Datos.Nombre + '''''')'' AS Dato2 '
Set @Observacion = @Observacion + 'FROM (SELECT Nombre, COUNT(*) AS NroVeces '
Set @Observacion = @Observacion + 'FROM (SELECT CodUsuario, ISNULL(Paterno, '''') + '' '' + ISNULL(Materno, '''') + '' '' + ISNULL(Nombres, '''') + CASE WHEN apeesposo IS NULL ' 
Set @Observacion = @Observacion + 'THEN '''' WHEN ltrim(rtrim(apeesposo)) = '''' THEN '''' ELSE '' DE '' END + ISNULL(ApeEsposo, '''') AS Nombre '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes '
Set @Observacion = @Observacion + 'UNION '
Set @Observacion = @Observacion + 'SELECT CodUsuario, nombrecompleto '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes) Datos '
Set @Observacion = @Observacion + 'GROUP BY Nombre '
Set @Observacion = @Observacion + 'HAVING (COUNT(*) > 1)) Datos INNER JOIN '
Set @Observacion = @Observacion + '(SELECT CodUsuario, ISNULL(Paterno, '''') + '' '' + ISNULL(Materno, '''') + '' '' + ISNULL(Nombres, '''') + CASE WHEN apeesposo IS NULL '
Set @Observacion = @Observacion + 'THEN '''' WHEN ltrim(rtrim(apeesposo)) = '''' THEN '''' ELSE '' DE '' END + ISNULL(ApeEsposo, '''') AS Nombre '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes '
Set @Observacion = @Observacion + 'UNION '
Set @Observacion = @Observacion + 'SELECT CodUsuario, nombrecompleto '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes) Maestro ON Datos.Nombre = Maestro.Nombre '
Set @Observacion = @Observacion + 'WHERE (Maestro.CodUsuario NOT IN '
Set @Observacion = @Observacion + '(SELECT Codusuario '
Set @Observacion = @Observacion + 'FROM tcshomonimia '
Set @Observacion = @Observacion + 'WHERE interna = 1)) '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)


-------------------------------------------------------------
Set @Tipo = '04: Códigos de Clientes con espacios en blanco'

Set @Observacion = 'SELECT CodOrigen, Paterno, Materno, Nombres, ''Exec spSgCambiaCodigoUsuario '''''' + RTRIM(CodOrigen) '
Set @Observacion = @Observacion + '+ '''''', ''''''+ CASE Len(Rtrim(Ltrim(SubString(CodUsuario, 1, 2)))) WHEN 2 THEN SubString(CodUsuario, 1, 2) '
Set @Observacion = @Observacion + 'ELSE CodOficina + CASE rtrim(ltrim(Substring(Paterno, 1, 1))) WHEN '''' THEN ''-'' ELSE rtrim(ltrim(Substring(Paterno, 1, 1))) '
Set @Observacion = @Observacion + 'END END + CASE rtrim(ltrim(Substring(Materno, 1, 1))) WHEN '''' THEN ''-'' ELSE rtrim(ltrim(Substring(Materno, 1, 1))) '
Set @Observacion = @Observacion + 'END + LTRIM(RTRIM(SUBSTRING(CodOrigen, 4, 25))) + '''''''' AS Solucion, FechaIngreso '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes '
Set @Observacion = @Observacion + 'WHERE (CHARINDEX('' '', RTRIM(CodUsuario)) > 0) '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-------------------------------------------------------------
Set @Tipo = '05: Duplicidad de Codigos de Clientes'

Set @Observacion = 'SELECT DISTINCT Fecha, CodOficina, NomOficina, NombreCompleto, CodTPersona, DescTPersona, DI '
Set @Observacion = @Observacion + 'FROM (SELECT tCsAhorros.Fecha, tCsAhorros.CodOficina, tClOficinas.NomOficina, tCsAhorros.CodCuenta, tCsAhorros.FraccionCta, tCsAhorros.Renovado, '

Set @Observacion = 'SELECT DISTINCT ' 
Set @Observacion = @Observacion + 'tCsClientes.CodUsuario, tCsPadronClientes.CodUsuario AS CodigoFinal, tCsClientes.Paterno, tCsClientes.Materno, tCsClientes.Nombres, '
Set @Observacion = @Observacion + 'tCsClientes.ApeEsposo, tCsClientes.CodDocIden, tCsClientes.DI, tCsClientes.UsRFC, tCsClientes.DireccionDirFamPri, tCsClientes.DireccionDirNegPri, '
Set @Observacion = @Observacion + 'tCsClientes.CodOficina, tCsClientes.CodOrigen, '
Set @Observacion = @Observacion + '''UPDATE tUsUsuarios SET CodDocIden = '''''' + tCsClientes.CodDocIden + '''''', DI = '''''' + tCsClientes.DI + '''''' WHERE CodUSuario = '''''' + RTRIM(LTRIM(tCsClientes.CodOrigen)) '
Set @Observacion = @Observacion + '+ '''''''' AS Cadena1, ''UPDATE tUsUsuarioSecundarios SET UsRUC = '''''' + ISNULL(tCsClientes.UsRFC, '''') '
Set @Observacion = @Observacion + '+ '''''' WHERE CodUSuario = '''''' + RTRIM(LTRIM(tCsClientes.CodOrigen)) + '''''''' AS Cadena2, '
Set @Observacion = @Observacion + 'CASE tCsClientes.CodOficina + LTRIM(RTRIM(tCsPadronClientes.CodUsuario)) WHEN RTRIM(LTRIM(tCsClientes.CodOrigen)) THEN NULL '
Set @Observacion = @Observacion + 'ELSE ''Exec spSgCambiaCodigoUsuario '''''' + RTRIM(LTRIM(tCsClientes.CodOrigen)) '
Set @Observacion = @Observacion + '+ '''''', '''''' + tCsClientes.CodOficina + LTRIM(RTRIM(tCsPadronClientes.CodUsuario)) + '''''''' END AS Cadena3 '
Set @Observacion = @Observacion + 'FROM (SELECT DISTINCT tCsPadronClientes.CodOriginal AS Antiguo, ''Prueba'' AS Nuevo '
Set @Observacion = @Observacion + 'FROM tCsClientes RIGHT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsPadronClientes ON tCsClientes.CodUsuario = tCsPadronClientes.CodUsuario '
Set @Observacion = @Observacion + 'WHERE (tCsClientes.CodUsuario IS NULL)) tTmpConsistenciaUsuario INNER JOIN '
Set @Observacion = @Observacion + 'tCsClientes ON tTmpConsistenciaUsuario.Antiguo = tCsClientes.CodUsuario LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsPadronClientes ON tCsClientes.CodDocIden = tCsPadronClientes.CodDocIden AND tCsClientes.DI = tCsPadronClientes.DI AND '
Set @Observacion = @Observacion + 'tCsClientes.CodUsuario = tCsPadronClientes.CodOriginal '
--Set @Observacion = @Observacion + 'ORDER BY tCsClientes.CodUsuario, tCsClientes.Paterno '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-------------------------------------------------------------
Set @Tipo = '06: Tablas que no tienen registros'

Set @Observacion = 'SELECT ''DROP TABLE '' + Tabla AS cadena, * '
Set @Observacion = @Observacion + 'FROM tCsPadronTablas '
Set @Observacion = @Observacion + 'WHERE (ActualFila = 0) AND (ActualData = 0) AND (FechaConsolidacion = '''+ dbo.fduFechaAAAAMMDD(@Fecha) +''')'

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)


-------------------------------------------------------------
Set @Tipo = '07: Inconsistencia de asesores BIS'

Set @Observacion = 'SELECT tCsPadronAsesores.CodAsesor, ''Asesor BIS Encontrado - Cliente : '' + tCsPadronClientes.NombreCompleto AS Observacion '
Set @Observacion = @Observacion + 'FROM tCsPadronAsesores LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsPadronClientes ON tCsPadronAsesores.CodAsesor = tCsPadronClientes.CodUsuario '
Set @Observacion = @Observacion + 'WHERE (tCsPadronAsesores.NomAsesor LIKE ''%BIS%'') '
--Set @Observacion = @Observacion + 'ORDER BY tCsPadronAsesores.CodOficina '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-------------------------------------------------------------
Set @Tipo = '08: Cuentas de ahorros que no poseen usuarios'

Set @Observacion = 'SELECT * '
Set @Observacion = @Observacion + 'FROM tCsAhorros '
Set @Observacion = @Observacion + 'WHERE (RTRIM(LTRIM(CodUsuario)) = '''') OR '
Set @Observacion = @Observacion + '(CodUsuario IS NULL)AND (Fecha = '''+ dbo.fduFechaAAAAMMDD(@Fecha) +''')'


IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)
-------------------------------------------------------------
Set @Tipo = '09: Clientes sin Nombre Completo'

Set @Observacion = 'SELECT ''UPDATE tUsUsuarios Set NombreCompleto = '''''' + CASE WHEN codestadocivil = ''C'' THEN apeesposo + '' '' + nombres + '' '' + paterno + '' DE'''''' ELSE paterno '
Set @Observacion = @Observacion + '+ '' '' + materno + '' '' + nombres + '''''''' END + '' WHERE CodUsuario = '''''' + RTRIM(LTRIM(CodOrigen)) + '''''''' AS Solucion, * '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes '
Set @Observacion = @Observacion + 'WHERE (RTRIM(LTRIM(NombreCompleto)) = '''') '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)


-------------------------------------------------------------
Set @Tipo = '10: Codigos de Clientes Inconsistentes a la Oficina'

Set @Observacion = 'SELECT CodOrigen, CodOficina, ''Exec spSgCambiaCodigoUsuario '''''' + RTRIM(LTRIM(CodOrigen)) ' 
Set @Observacion = @Observacion + '+ '''''', '''''' + CodOficina + CASE len(ISNULL(SUBSTRING(RTRIM(LTRIM(Paterno)), 1, 1), ''-'')) ' 
Set @Observacion = @Observacion + 'WHEN 0 THEN ''-'' ELSE ISNULL(SUBSTRING(RTRIM(LTRIM(Paterno)), 1, 1), ''-'') END + CASE len(ISNULL(SUBSTRING(RTRIM(LTRIM(materno)), 1, 1), ''-'')) ' 
Set @Observacion = @Observacion + 'WHEN 0 THEN ''-'' ELSE ISNULL(SUBSTRING(RTRIM(LTRIM(materno)), 1, 1), ''-'') END + CASE len(ISNULL(SUBSTRING(RTRIM(LTRIM(nombres)), 1, 1), ''-'')) ' 
Set @Observacion = @Observacion + 'WHEN 0 THEN ''-'' ELSE ISNULL(SUBSTRING(RTRIM(LTRIM(nombres)), 1, 1), ''-'') END + SUBSTRING(dbo.fdufechaDDMMAAAA(FechaNacimiento), 1, 4) ' 
Set @Observacion = @Observacion + '+ SUBSTRING(dbo.fdufechaDDMMAAAA(FechaNacimiento), 7, 2) + RIGHT(RTRIM(LTRIM(CodOrigen)), 1) + '''''''' AS Cadena '
Set @Observacion = @Observacion + 'FROM tCsClientes '
Set @Observacion = @Observacion + 'WHERE (SUBSTRING(CodOrigen, 1, LEN(LTRIM(RTRIM(CodOficina)))) <> LTRIM(RTRIM(CodOficina)))'

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-------------------------------------------------------------
Set @Tipo = '11: Sin relación cartera con Padron de Cartera'

Set @Observacion = 'SELECT DISTINCT '
Set @Observacion = @Observacion + 'Datos.CodPrestamo, Datos.NombreCompleto, Datos.CodUsuario, tCsCarteraDet.CodUsuario AS Posible, tCsPadronClientes.NombreCompleto AS Probable, '
Set @Observacion = @Observacion + 'ISNULL(tCsPadronCarteraDet.CodUsuario, ''POSIBLE'') AS Valida, tCsCartera.CodUsuario AS Coordinador, '
Set @Observacion = @Observacion + '''UPDATE tCsPadronCarteraDet Set CodUsuario = '''''' + RTRIM(LTRIM(tCsCarteraDet.CodUsuario)) '
Set @Observacion = @Observacion + '+ '''''' WHERE CodPrestamo = '''''' + RTRIM(LTRIM(Datos.CodPrestamo)) + '''''' AND CodUsuario = '''''' + RTRIM(LTRIM(Datos.CodUsuario)) '
Set @Observacion = @Observacion + '+ '''' AS Cadena '
Set @Observacion = @Observacion + 'FROM tCsPadronClientes INNER JOIN '
Set @Observacion = @Observacion + 'tCsCarteraDet ON tCsPadronClientes.CodUsuario = tCsCarteraDet.CodUsuario LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsPadronCarteraDet ON tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte AND '
Set @Observacion = @Observacion + 'tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND '
Set @Observacion = @Observacion + 'tCsCarteraDet.CodUsuario = tCsCartera.CodUsuario RIGHT OUTER JOIN '
Set @Observacion = @Observacion + '(SELECT DISTINCT '
Set @Observacion = @Observacion + 'tCsPadronCarteraDet.fechacorte, tCsPadronCarteraDet.CodPrestamo, tCsPadronClientes.NombreCompleto, '
Set @Observacion = @Observacion + 'tCsPadronCarteraDet.CodUsuario '
Set @Observacion = @Observacion + 'FROM tCsPadronCarteraDet LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN '
Set @Observacion = @Observacion + 'tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND '
Set @Observacion = @Observacion + 'tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha AND tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario '
Set @Observacion = @Observacion + 'WHERE (tCsCarteraDet.CodUsuario IS NULL)) Datos ON tCsCarteraDet.CodPrestamo = Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI AND '
Set @Observacion = @Observacion + 'tCsCarteraDet.Fecha = Datos.fechacorte '

IF @Tip = Cast(Substring(@Tipo, 1, 2)as Int)
	Begin
	Set @Temporal = @Observacion
	End
Set @Cadena = 'INSERT INTO #Observaciones Select Tipo = '''+ @Tipo +''', Count(*) as Contador From('+ @Observacion + ')Datos'
Print @Tipo
Print @Observacion
Print @Cadena
Exec(@Cadena)

-----------------------\
--FINMAS ++++++++++++++++>>>
-----------------------/

Select * from #Observaciones
Drop Table #Observaciones
Print @Temporal
Exec(@Temporal)

GO