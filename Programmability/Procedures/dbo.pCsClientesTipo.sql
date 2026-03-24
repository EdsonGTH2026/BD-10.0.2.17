SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop procedure pCsClientesTipo
CREATE Procedure [dbo].[pCsClientesTipo]
@Dato		Int,
@Fecha		SmallDateTime,
@Ubicacion	Varchar(500)
As

-- 1: Es cuando se desea visualizar todos los perfiles.
-- 2: Es cuando solo se desea visualizar los Perfiles mas significativos.
-- 3: Actualiza Datos en tCsPadronClientes campos:  "ClienteDe" y "Activo"
-- 4: Para Grafico de Clientes por Periodo

--Set @Ubicacion	= 'ZZZ'
--Set @Fecha		= '20101104'

Declare @CUbicacion		Varchar(1000)
Declare @OtroDato		Varchar(1000)
Declare @Cadena			Varchar(8000)
Declare @Cadena1		Varchar(8000)
Declare @Cadena2		Varchar(8000)
Declare @Cadena3		Varchar(8000)
Declare @Cadena4		Varchar(8000)
Declare @Cadena5		Varchar(8000)
Declare @Cadena6		Varchar(8000)
Declare @Cadena7		Varchar(8000)
Declare @Cadena8		Varchar(8000)
Declare @Cadena9		Varchar(8000)
Declare @Cadena10		Varchar(8000)
Declare @Cadena11		Varchar(8000)
Declare @Cadena12		varchar(8000)
Declare @Cadena13		varchar(8000)
Declare @Cadena14		varchar(8000)
Declare @Cadena15		varchar(8000)

Declare @TotalClientes	Int
Declare @Tipo			Varchar(50)
Declare	@Identificador	Varchar(2)
Declare @UZ				Varchar(50)
Declare @Otros			Varchar(5)

Set @Otros = 1.1

If Charindex('Z', UPPER(@Ubicacion)) > 0 
Begin
	Set @UZ = 'CodOficinaFinal'
End
Else
Begin
	Set @UZ = 'CodOficinaFinal'
End

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out

Create Table #Valor 
(
Valor Decimal(30,9)
)

Set @Cadena5	= 'Tipo = Case Activo When 0 Then ''Clientes Inactivos'' When 1 Then ''Clientes Activos'' End'

Set @Cadena4	= 'SELECT CodUsuario, MAX(CAST(Activo AS Int)) AS Activo FROM tCsPadronClientesTipo '
Set @Cadena4	= @Cadena4 + 'WHERE (Fecha = '''+  dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''') AND ('+ @UZ +' IN ('+ @CUbicacion +')) '
Set @Cadena4	= @Cadena4 + 'GROUP BY CodUsuario'

Set @Cadena		= 'Insert Into #Valor '
Set @Cadena		= @Cadena + 'SELECT COUNT(*) As Contador FROM ('+ @Cadena4 +') Datos '

Print @Cadena
Exec (@Cadena)

Select @TotalClientes = Valor From #Valor
Drop Table #Valor

Set @Cadena1	= ''
Set @Cadena2	= ''
Set @Cadena3	= ''
Set @Cadena10	= ''
Set @Cadena11	= ''
Set @Cadena12	= ''
Set @Cadena13	= ''
Set @Cadena14	= ''
Declare curTipo Cursor For 
	SELECT     Tipo, Identificador
	FROM         tCsClientesTipo
	WHERE     (Activo = 1)
Open curTipo
Fetch Next From curTipo Into @Tipo, @Identificador
While @@Fetch_Status = 0
Begin 
	Set @Cadena1	= @Cadena1	+ ', CASE WHEN Tipo = ''' + @Tipo + ''' THEN 1 ELSE 0 END AS '+ @Identificador 
	Set @Cadena2	= @Cadena2	+ @Identificador + ', '
	Set @Cadena3	= @Cadena3	+ ', SUM(' + @Identificador + ') AS ' + @Identificador
	Set @Cadena10	= @Cadena10	+ 'ISNULL(Inactivos.' + @Identificador + ', Activos.' + @Identificador + ') AS ' + @Identificador + ', '
	Set @Cadena11	= @Cadena11	+ 'AND Inactivos.' + @Identificador + ' = Activos.' + @Identificador + ' '
	Set @Cadena12	= @Cadena12 + 'Case When ' + @Identificador + ' = 1 Then ''' + @Identificador + ''' Else '''' End + '
	Set @Cadena13	= @Cadena13 + 'Datos.' + @Identificador + ' * Datos.ClientesI AS ' + @Identificador + 'I, Datos.' + @Identificador + ' * Datos.ClientesA AS ' + @Identificador + 'A, '
	Set @Cadena14	= @Cadena14 + 'SUM(' + @Identificador + 'I) As '+ @Identificador +'I, SUM(' + @Identificador + 'A) As '+ @Identificador +'A, '
Fetch Next From curTipo Into @Tipo, @Identificador
End 
Close 		curTipo
Deallocate 	curTipo
Set @Cadena2	= Left(Ltrim(Rtrim(@Cadena2)), len(Ltrim(Rtrim(@Cadena2))) - 1)
Set @Cadena12	= Left(Ltrim(Rtrim(@Cadena12)), len(Ltrim(Rtrim(@Cadena12))) - 1)

Set @Cadena6 = 'Select Fecha = Cast(''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''' as SmallDateTime), Ubicacion = ''' + dbo.fdurellena(' ', @Ubicacion, 100, 'I')  + ''', ' + @Cadena5 + ', '+ @Cadena2 +', Clientes, Porcentaje, C, P '
Set @Cadena6 = @Cadena6 + 'From (SELECT '+ @Cadena2 +', dbo.fduNumeroTexto(COUNT(*), 0) '
Set @Cadena6 = @Cadena6 + 'AS Clientes, Activo, Porcentaje = dbo.fduNumeroTexto(COUNT(*)/Cast('+ Ltrim(rtrim(str(@TotalClientes, 10,0))) +' as Decimal(10,4))*100, 2)+ ''%'', COUNT(*) AS C, P = COUNT(*) / Cast('+ Ltrim(rtrim(str(@TotalClientes, 10,0))) +' as Decimal(10,4))*100 '
Set @Cadena6 = @Cadena6 + 'FROM (SELECT CodUsuario'+ @Cadena3 +', Activo FROM ('
Set @Cadena6 = @Cadena6 + 'SELECT Principal.CodUsuario, Principal.Activo, Tipos.Tipo'+ @Cadena1 +' FROM ('+ @Cadena4 +') Principal INNER JOIN '
Set @Cadena6 = @Cadena6 + '(SELECT * FROM tCsPadronClientesTipo WHERE (Fecha = '''+  dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''')) Tipos ON Principal.CodUsuario = Tipos.CodUsuario '
Set @Cadena6 = @Cadena6 + 'XXXXXXXXXXXXXXXXXX) Datos GROUP BY CodUsuario, Activo) Datos GROUP BY '+ @Cadena2 +', Activo) Datos '

If @Dato in (3)
Begin
	Set @Cadena = 'UPDATE tCsPadronClientes Set ClienteDe = Datos.Perfil, Activo = Datos.Activo FROM (Select CodUsuario, Perfil = '+ @Cadena12 +', Activo from (SELECT CodUsuario, '+ @Cadena2 +', dbo.fduNumeroTexto(COUNT(*), 0) '
	Set @Cadena = @Cadena + 'AS Clientes, Activo, Porcentaje = dbo.fduNumeroTexto(COUNT(*)/Cast('+ Ltrim(rtrim(str(@TotalClientes, 10,0))) +' as Decimal(10,4))*100, 2)+ ''%'', COUNT(*) AS C, P = COUNT(*) / Cast('+ Ltrim(rtrim(str(@TotalClientes, 10,0))) +' as Decimal(10,4))*100 '
	Set @Cadena = @Cadena + 'FROM (SELECT CodUsuario'+ @Cadena3 +', Activo FROM ('
	Set @Cadena = @Cadena + 'SELECT Principal.CodUsuario, Principal.Activo, Tipos.Tipo'+ @Cadena1 +' FROM ('+ @Cadena4 +') Principal INNER JOIN '
	Set @Cadena = @Cadena + '(SELECT * FROM tCsPadronClientesTipo WHERE (Fecha = '''+  dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''')) Tipos ON Principal.CodUsuario = Tipos.CodUsuario '
	Set @Cadena = @Cadena + ') Datos GROUP BY CodUsuario, Activo) Datos GROUP BY CodUsuario, '+ @Cadena2 +', Activo) P) AS Datos INNER JOIN tCsPadronClientes ON Datos.CodUsuario = tCsPadronClientes.CodUsuario '
End

--DETALLE INACTIVOS
Set @Cadena7 = Replace(@Cadena6, 'XXXXXXXXXXXXXXXXXX', 'WHERE (Principal.Activo In(0))')
Set @Cadena8 = 'SELECT  Fecha, Ubicacion, '+ @Cadena2 +', C AS ClientesI, P AS PorcentajeI '
Set @Cadena8 = @Cadena8 + 'FROM (' + @Cadena7 + ') Datos '

--DETALLE ACTIVOS
Set @Cadena7 = Replace(@Cadena6, 'XXXXXXXXXXXXXXXXXX', 'WHERE (Principal.Activo In(1))')
Set @Cadena9 = 'SELECT  Fecha, Ubicacion, '+ @Cadena2 +', C AS ClientesA, P AS PorcentajeA '
Set @Cadena9 = @Cadena9 + 'FROM (' + @Cadena7 + ') Datos '

If @Dato = 1
Begin
	Set @Cadena = 'SELECT Datos.Fecha, Datos.Ubicacion, Datos.Perfil, tCsClientesPerfil.Nombre, tCsClientesPerfil.Descripcion, '
	Set @Cadena = @Cadena + @Cadena13 + ' Datos.ClientesI, Datos.PorcentajeI, Datos.ClientesA, Datos.PorcentajeA, Datos.Clientes, Datos.Porcentaje FROM ( '
	Set @Cadena = @Cadena + 'SELECT *, ClientesI + ClientesA AS Clientes, PorcentajeI + PorcentajeA AS Porcentaje, Perfil =  '+ @Cadena12 +' FROM (SELECT ISNULL(Inactivos.Fecha, Activos.Fecha) AS Fecha, ISNULL(Inactivos.Ubicacion, Activos.Ubicacion) AS Ubicacion, '
	Set @Cadena = @Cadena + @Cadena10 + ' ISNULL(Inactivos.ClientesI, 0) AS ClientesI, ISNULL(Inactivos.PorcentajeI, 0) AS PorcentajeI, ISNULL(Activos.ClientesA, 0) AS ClientesA, ISNULL(Activos.PorcentajeA, 0) AS PorcentajeA '
	Set @Cadena = @Cadena + 'FROM (' + @Cadena8 + ') Inactivos FULL OUTER JOIN (' + @Cadena9 + ') Activos ON Inactivos.Fecha = Activos.Fecha AND Inactivos.Ubicacion = Activos.Ubicacion '
	Set @Cadena = @Cadena + @Cadena11 + ')Datos) Datos LEFT OUTER JOIN tCsClientesPerfil ON Datos.Perfil COLLATE Modern_Spanish_CI_AI = tCsClientesPerfil.Perfil'
End

If @Dato = 2
Begin

	--Update tCsPadronClientes
	--Set 	Activo 		= 0,
	--	ClienteDe 	= ''	

	Set @Cadena = 'SELECT Datos.Fecha, Datos.Ubicacion, '
	Set @Cadena = @Cadena + 'Perfil = Case When Round(Datos.Porcentaje,0) >= '+ @Otros +' Then Datos.Perfil Else ''T'' End, '
	Set @Cadena = @Cadena + 'Nombre = Case When Round(Datos.Porcentaje,0) >= '+ @Otros +' Then tCsClientesPerfil.Nombre Else ''OTROS PERFILES'' End, '
	Set @Cadena = @Cadena + 'Descripcion = Case When Round(Datos.Porcentaje,0) >= '+ @Otros +' Then tCsClientesPerfil.Descripcion Else ''Se considera a todo el resto de clientes cuyos perfiles en cantidad no son significativos'' End, '
	Set @Cadena = @Cadena + @Cadena13 + ' Datos.ClientesI, Datos.PorcentajeI, Datos.ClientesA, Datos.PorcentajeA, Datos.Clientes, Datos.Porcentaje FROM ( '
	Set @Cadena = @Cadena + 'SELECT *, ClientesI + ClientesA AS Clientes, PorcentajeI + PorcentajeA AS Porcentaje, Perfil =  '+ @Cadena12 +' FROM (SELECT ISNULL(Inactivos.Fecha, Activos.Fecha) AS Fecha, ISNULL(Inactivos.Ubicacion, Activos.Ubicacion) AS Ubicacion, '
	Set @Cadena = @Cadena + @Cadena10 + ' ISNULL(Inactivos.ClientesI, 0) AS ClientesI, ISNULL(Inactivos.PorcentajeI, 0) AS PorcentajeI, ISNULL(Activos.ClientesA, 0) AS ClientesA, ISNULL(Activos.PorcentajeA, 0) AS PorcentajeA '
	Set @Cadena = @Cadena + 'FROM (' + @Cadena8 + ') Inactivos FULL OUTER JOIN (' + @Cadena9 + ') Activos ON Inactivos.Fecha = Activos.Fecha AND Inactivos.Ubicacion = Activos.Ubicacion '
	Set @Cadena = @Cadena + @Cadena11 + ')Datos) Datos LEFT OUTER JOIN tCsClientesPerfil ON Datos.Perfil COLLATE Modern_Spanish_CI_AI = tCsClientesPerfil.Perfil'
End

If @Dato in (1, 2)
Begin
	Set @Cadena = 'Select C = Count(*), Fecha, Ubicacion, Perfil, Nombre, Descripcion, ' + @Cadena14 + 'SUM(ClientesI) as ClientesI, SUM(PorcentajeI) as PorcentajeI, SUM(ClientesA) as ClientesA, SUM(PorcentajeA) as PorcentajeA, SUM(Clientes) AS Clientes, SUM(Porcentaje) as Porcentaje From (' + @Cadena + ')Datos Group By Fecha, Ubicacion, Perfil, Nombre, Descripcion '
End

If @Dato in (4)
Begin
	Create Table #Clientes
	(
		Fecha		SmallDateTime,
		Tipo		Varchar(50),
		Clientes	Int
	)
		
	Set @Cadena = 'Insert Into #Clientes SELECT Fecha, Case Activo When 0 Then ''INACTIVO'' When 1 Then ''ACTIVO'' End as Tipo , COUNT(*) AS '
	Set @Cadena = @Cadena + 'Clientes FROM (SELECT tCsPadronClientesTipo.Fecha, tCsPadronClientesTipo.Conclusion as Activo, tCsPadronClientesTipo.CodUsuario '
	Set @Cadena = @Cadena + 'FROM tCsPadronClientesTipo INNER JOIN tClPeriodo ON tCsPadronClientesTipo.Fecha = tClPeriodo.UltimoDia WHERE '
	Set @Cadena = @Cadena + '(tCsPadronClientesTipo.'+ @UZ +' IN ('+ @CUbicacion +')) AND (tCsPadronClientesTipo.Fecha >= DATEADD(Month, - 12, '
	Set @Cadena = @Cadena + ''''+  dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''')) AND (tCsPadronClientesTipo.Fecha <= '
	Set @Cadena = @Cadena + ''''+  dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''') GROUP BY tCsPadronClientesTipo.Fecha, '
	Set @Cadena = @Cadena + 'tCsPadronClientesTipo.Conclusion, tCsPadronClientesTipo.CodUsuario) AS Datos GROUP BY Fecha, Activo '
	
	Print @Cadena
	Exec (@Cadena)
	
	Set @Cadena = 'Insert Into #Clientes Select Fecha, Tipo = ''TOTAL'', Sum(Clientes) as Clientes from #Clientes Group by Fecha '
	
	Print @Cadena
	Exec (@Cadena)
	
	Set @Cadena = 'Select * from #Clientes'
End 

Print @Cadena
Exec (@Cadena)

/*
SELECT   TIpo = 'CA',   COUNT(*) AS Clientes
FROM         (SELECT DISTINCT CodUsuario
                       FROM          tCsCarteraDet
                       WHERE      (Fecha <= @Fecha)) Datos
UNION
SELECT   TIpo = 'AH',   COUNT(*) AS Clientes
FROM         (SELECT     CodUsCuenta
	                       FROM          tCsClientesAhorrosFecha
	                       WHERE      (Fecha <= @Fecha)
	                       UNION
	                       SELECT     CodUsuario
	                       FROM         tCsAhorros
	                       WHERE     (Fecha <= @Fecha)) Datos        
*/
GO