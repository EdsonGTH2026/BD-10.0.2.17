SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROCEDURE pCsApellidoExtraño
Create Procedure [dbo].[pCsApellidoExtraño]
@Nombre      	Varchar(100),
@Usuario	Varchar(100)

--Declare @Nombre      	Varchar(100)
--Declare @Usuario	Varchar(100)
--Set @Usuario 	= 'Aayalar'
--Set @Nombre 	= 'SALAZAR TULES ANTONIA'

--UPDATE tcsApellidos Set Extraño = 0 where Apellido = 'TULES' 
--UPDATE tcsApellidos Set Referencia = NUll
AS
Declare @CodUsuario  	Varchar(15) 
Declare @Cadena		Varchar(4000)
Declare @Firma		Varchar(100)
Declare @Filas		Int

Exec pCsNombreACodigo 		@Nombre, 	@CodUsuario Out 
Set @CodUsuario = Ltrim(Rtrim(@CodUsuario))
Exec pCsFirmaElectronica 	@Usuario, 	'SG', 		@CodUsuario, @Firma Out

Set @Filas = 0

SELECT    @Usuario =  tCsPadronClientes.NombreCompleto
FROM      tSgUsuarios INNER JOIN
          tCsPadronClientes ON tSgUsuarios.CodUsuario = tCsPadronClientes.CodUsuario
WHERE     (tSgUsuarios.Usuario = @Usuario)

UPDATE tCsApellidos
Set Extraño = 1, Referencia = @Usuario
FROM         tCsPadronClientes INNER JOIN
                      tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
WHERE     (tCsPadronClientes.CodUsuario = @CodUsuario) and Cantidad <= 2 And Extraño = 0
Set @Filas = @Filas +  @@RowCount  

UPDATE tCsApellidos
Set Extraño = 1, Referencia = @Usuario
FROM         tCsPadronClientes INNER JOIN
                      tCsApellidos ON tCsPadronClientes.Materno = tCsApellidos.Apellido
WHERE     (tCsPadronClientes.CodUsuario = @CodUsuario) and Cantidad <= 2 And Extraño = 0
Set @Filas = @Filas +  @@RowCount  

UPDATE tCsApellidos
Set Extraño = 1, Referencia = @Usuario
FROM         tCsPadronClientes INNER JOIN
                      tCsApellidos ON tCsPadronClientes.ApeEsposo = tCsApellidos.Apellido
WHERE     (tCsPadronClientes.CodUsuario = @CodUsuario) and Cantidad <= 2 And Extraño = 0
Set @Filas = @Filas +  @@RowCount  

If @Filas = 0
Begin
	DELETE FROM tCsFirmaElectronica WHERE Firma = @Firma
End

SELECT @Cadena = 'UPDATE tCsApellidos SET Referencia = tCsPadronClientes_1.NombreCompleto FROM tCsPadronClientes INNER JOIN tCsApellidos ON tCsPadronClientes.' + CASE substring(MIN(Parametro),
                       9, 1) 
                      WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = tCsApellidos.Apellido INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario WHERE (tCsPadronClientes.'
                       + CASE substring(MIN(Parametro), 9, 1) 
                      WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = ''' + LTRIM(RTRIM(SUBSTRING(MIN(Parametro), 10, 50))) 
                      + ''') AND (dbo.fduFechaATexto(tCsPadronClientes.FechaIngreso, ''AAAAMMDD'') = ''' + LEFT(MIN(Parametro), 8) + ''')' 
FROM         (SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'P' + Apellido AS Parametro
                       FROM          (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                               FROM          tCsPadronClientes INNER JOIN
                                                                      tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                          (SELECT     tCsApellidos.Apellido
                                                                            FROM          tCsPadronClientes INNER JOIN
                                                                                                   tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
                                                                            WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                      tCsPadronClientes.Paterno = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                               GROUP BY Paterno.Apellido) Datos
                       UNION
                       SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'M' + Apellido AS Parametro
                       FROM         (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                              FROM          tCsPadronClientes INNER JOIN
                                                                     tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                         (SELECT     tCsApellidos.Apellido
                                                                           FROM          tCsPadronClientes INNER JOIN
                                                                                                  tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
                                                                           WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                     tCsPadronClientes.Materno = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                              GROUP BY Paterno.Apellido) Datos
                       UNION
                       SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'E' + Apellido AS Parametro
                       FROM         (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                              FROM          tCsPadronClientes INNER JOIN
                                                                     tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                         (SELECT     tCsApellidos.Apellido
                                                                           FROM          tCsPadronClientes INNER JOIN
                                                                                                  tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
                                                                           WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                     tCsPadronClientes.ApeEsposo = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                              GROUP BY Paterno.Apellido) Datos) Datos
Exec (@Cadena)

SELECT @Cadena = 'UPDATE tCsApellidos SET Referencia = tCsPadronClientes_1.NombreCompleto FROM tCsPadronClientes INNER JOIN tCsApellidos ON tCsPadronClientes.' + CASE substring(MIN(Parametro),
                       9, 1) 
                      WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = tCsApellidos.Apellido INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario WHERE (tCsPadronClientes.'
                       + CASE substring(MIN(Parametro), 9, 1) 
                      WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = ''' + LTRIM(RTRIM(SUBSTRING(MIN(Parametro), 10, 50))) 
                      + ''') AND (dbo.fduFechaATexto(tCsPadronClientes.FechaIngreso, ''AAAAMMDD'') = ''' + LEFT(MIN(Parametro), 8) + ''')' 
FROM         (SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'P' + Apellido AS Parametro
                       FROM          (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                               FROM          tCsPadronClientes INNER JOIN
                                                                      tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                          (SELECT     tCsApellidos.Apellido
                                                                            FROM          tCsPadronClientes INNER JOIN
                                                                                                   tCsApellidos ON tCsPadronClientes.Materno = tCsApellidos.Apellido
                                                                            WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                      tCsPadronClientes.Paterno = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                               GROUP BY Paterno.Apellido) Datos
                       UNION
                       SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'M' + Apellido AS Parametro
                       FROM         (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                              FROM          tCsPadronClientes INNER JOIN
                                                                     tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                         (SELECT     tCsApellidos.Apellido
                                                                           FROM          tCsPadronClientes INNER JOIN
                                                                                                  tCsApellidos ON tCsPadronClientes.Materno = tCsApellidos.Apellido
                                                                           WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                     tCsPadronClientes.Materno = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                              GROUP BY Paterno.Apellido) Datos
                       UNION
                       SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'E' + Apellido AS Parametro
                       FROM         (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                              FROM          tCsPadronClientes INNER JOIN
                                                                     tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                         (SELECT     tCsApellidos.Apellido
                                                                           FROM          tCsPadronClientes INNER JOIN
                                                                                                  tCsApellidos ON tCsPadronClientes.Materno = tCsApellidos.Apellido
                                                                           WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                     tCsPadronClientes.ApeEsposo = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                              GROUP BY Paterno.Apellido) Datos) Datos
Exec (@Cadena)

SELECT @Cadena = 'UPDATE tCsApellidos SET Referencia = tCsPadronClientes_1.NombreCompleto FROM tCsPadronClientes INNER JOIN tCsApellidos ON tCsPadronClientes.' + CASE substring(MIN(Parametro),
                       9, 1) 
                      WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = tCsApellidos.Apellido INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario WHERE (tCsPadronClientes.'
                       + CASE substring(MIN(Parametro), 9, 1) 
                      WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = ''' + LTRIM(RTRIM(SUBSTRING(MIN(Parametro), 10, 50))) 
                      + ''') AND (dbo.fduFechaATexto(tCsPadronClientes.FechaIngreso, ''AAAAMMDD'') = ''' + LEFT(MIN(Parametro), 8) + ''')' 
FROM         (SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'P' + Apellido AS Parametro
                       FROM          (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                               FROM          tCsPadronClientes INNER JOIN
                                                                      tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                          (SELECT     tCsApellidos.Apellido
                                                                            FROM          tCsPadronClientes INNER JOIN
                                                                                                   tCsApellidos ON tCsPadronClientes.ApeEsposo = tCsApellidos.Apellido
                                                                            WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                      tCsPadronClientes.Paterno = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                               GROUP BY Paterno.Apellido) Datos
                       UNION
                       SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'M' + Apellido AS Parametro
                       FROM         (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                              FROM          tCsPadronClientes INNER JOIN
                                                                     tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                         (SELECT     tCsApellidos.Apellido
                                                                           FROM          tCsPadronClientes INNER JOIN
                                                                                                  tCsApellidos ON tCsPadronClientes.ApeEsposo = tCsApellidos.Apellido
                                                                           WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                     tCsPadronClientes.Materno = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                              GROUP BY Paterno.Apellido) Datos
                       UNION
                       SELECT     dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'E' + Apellido AS Parametro
                       FROM         (SELECT     Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                                              FROM          tCsPadronClientes INNER JOIN
                                                                     tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario INNER JOIN
                                                                         (SELECT     tCsApellidos.Apellido
                                                                           FROM          tCsPadronClientes INNER JOIN
                                                                                                  tCsApellidos ON tCsPadronClientes.ApeEsposo = tCsApellidos.Apellido
                                                                           WHERE      (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')) Paterno ON 
                                                                     tCsPadronClientes.ApeEsposo = Paterno.Apellido COLLATE Modern_Spanish_CI_AI
                                              GROUP BY Paterno.Apellido) Datos) Datos
Exec (@Cadena)

Exec pCsFrase @Cadena Out

SELECT Firma = @Firma, Usuario = @Usuario, * , Frase = @Cadena
FROM	(
SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto, Tipo = '01 Paterno', Apellido, 
	   Case tCsApellidos.Extraño 	When 1 Then 'Si' Else 'No' End As Extraño, 
	   Case tCsApellidos.Verificado When 1 Then 'Si' Else 'No' End As Verificado, 
           tCsApellidos.Registro, tCsApellidos.Cantidad, Isnull(tCsApellidos.Referencia, 'Ninguna') as Referencia
FROM         tCsPadronClientes INNER JOIN
                      tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
WHERE     (tCsPadronClientes.CodUsuario = @CodUsuario)
UNION
SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto, Tipo = '02 Materno', Apellido, 
	   Case tCsApellidos.Extraño 	When 1 Then 'Si' Else 'No' End As Extraño, 
	   Case tCsApellidos.Verificado When 1 Then 'Si' Else 'No' End As Verificado, 
           tCsApellidos.Registro, tCsApellidos.Cantidad, Isnull(tCsApellidos.Referencia, 'Ninguna') as Referencia
FROM         tCsPadronClientes INNER JOIN
                      tCsApellidos ON tCsPadronClientes.Materno = tCsApellidos.Apellido
WHERE     (tCsPadronClientes.CodUsuario = @CodUsuario)
UNION
SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto, Tipo = '03 Conyuge', Apellido, 
	   Case tCsApellidos.Extraño 	When 1 Then 'Si' Else 'No' End As Extraño, 
	   Case tCsApellidos.Verificado When 1 Then 'Si' Else 'No' End As Verificado, 
           tCsApellidos.Registro, tCsApellidos.Cantidad, Isnull(tCsApellidos.Referencia, 'Ninguna') as Referencia
FROM         tCsPadronClientes INNER JOIN
                      tCsApellidos ON tCsPadronClientes.ApeEsposo = tCsApellidos.Apellido
WHERE     (tCsPadronClientes.CodUsuario = @CodUsuario)) Datos
GO