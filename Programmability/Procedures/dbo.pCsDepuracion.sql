SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsDepuracion]
@Dato		Int,
@Usuario	Varchar(100),
@Dato1		Varchar(100),
@Dato2		Varchar(100)
AS
set nocount on 
-- 10: Para Apellidos Extraños	[07].
-- 20: Para Arreglar RFC		[13].	

-- 0 SIN Calificación Automática.
-- 1 CON Calificación Automática.
-- 2 No Actualiza y no muestra registros y queda pendiente el resultado el tabla de padron del SAT.

-- Si el siguiente numero es 1 entonces se recalcula calificación de Agencias.

--Variables Generales	:
Declare @Proceso		Char(100)		-- Para idnetificar el proceso a realizar. 
Declare @CodUsuario  	Varchar(15)		-- Se usa para identificar al Cliente del cual se arreglará su información.
Declare @Firma			Varchar(100)	-- Se usa para determinar el Sello Electronico.
Declare @Filas			Int				-- Se usa para determinar las filas afectadas por el proceso.
Declare @CodUsuarioF  	Varchar(15)		-- Se usa para identificar al Cliente en el FINMAS.
Declare @CodUsuarioC  	Varchar(15)		-- Se usa para identificar al Cliente en el CONSOLIDADO.
Declare @CodUsuarioU  	Varchar(15)		-- Se usa para identificar al Usuario en el FINMAS.
Declare @Fecha			SmallDateTime	-- Fecha ultima de las observaciones encontradas.
Declare @CodOficina		Varchar(4)		-- Codigo de Oficina del cual se volvera a realizar la calificación.
Declare @Calificacion	Int				-- Si el Valor es uno se recalifica la agencia.

Set @Calificacion	= @Dato%10
Set @Dato			= @Dato/10

Select @Fecha = Max(fecha)From tCsClientesObservaciones

--Variables Especificas	:
Declare @Cadena		Varchar(4000)
Declare @Nacimiento	SmallDateTime

Set @Dato1 = ltrim(rtrim(@Dato1))
Set @Dato2 = ltrim(rtrim(@Dato2))
--------------------------------------------------------
--SECCION: DE SELLO ELECTRONICO Y DEFINICION DEL PROCESO
--------------------------------------------------------
If @Dato = 1 -- Se realiza con el Consolidado
Begin
	Set @Proceso = 'REGISTRO DE APELLIDO EXTRAÑO'
	Exec pCsNombreACodigo 		@Dato1, 	@CodUsuario Out	
	Set @CodUsuarioC = @CodUsuario
	Set @CodUsuarioF = (Select CodOrigen From tCsPadronClientes Where CodUsuario = @CodUsuario)
End
If @Dato = 2 -- Se realiza con la Operativa
Begin
	Set @Proceso = 'CAMBIO DEL RFC DEL CLIENTE'
	
	SELECT @CodUsuario =  Max(CodUsuario)
	FROM (
	    Select CodOrigen as CodUsuario 
	    from tCsPadronClientes 
	    Where Ltrim(rtrim(UsRfc)) = @Dato1 -- noel - 2015 05 22 - aqui se puede poner un indice en UsRfc quitando ltrim y rtrim
	) Usuarios
	
	Set @CodUsuarioC = (Select CodUsuario From tCsPadronClientes Where CodOrigen = @CodUsuario)
	Set @CodUsuarioF = @CodUsuario
End
------------------------------------
--SECCION: DE PROCESO PRINCIPAL
------------------------------------
Set @CodUsuario		= Ltrim(Rtrim(@CodUsuario))	
Set @CodUsuarioC	= Ltrim(Rtrim(@CodUsuarioC))	
--Print Isnull(@CodUsuario, 'Código Nulo')
--Print GetDAte()
--Print 'CodUsuario : ' + Isnull(@CodUsuario, '')

If Rtrim(Ltrim(IsNull(@CodUsuario, ''))) <> '' 
Begin
	Exec pCsFirmaElectronica 	@Usuario, 	'SG', 		@CodUsuario, @Firma Out	
End

SELECT @Usuario     = C.NombreCompleto, 
       @CodUsuarioU	= Ltrim(rtrim(C.CodOrigen))
FROM   tSgUsuarios U
INNER JOIN tCsPadronClientes C ON U.CodUsuario = C.CodUsuario
WHERE  U.Usuario = @Usuario

Set @Filas	= 0
If Rtrim(Ltrim(IsNull(@CodUsuario, ''))) <> '' 
Begin	
	If @Dato = 1
	Begin	
		UPDATE tCsApellidos
		Set Extraño = 1, Referencia = @Usuario
		FROM tCsPadronClientes C
		where C.Paterno = tCsApellidos.Apellido
		AND   C.CodUsuario = @CodUsuario and Cantidad <= 2 And Extraño = 0
		
		Set @Filas = @Filas +  @@RowCount

		UPDATE tCsApellidos
		Set  Extraño = 1, Referencia = @Usuario
		FROM tCsPadronClientes C
		WHERE C.Materno = tCsApellidos.Apellido
		AND   C.CodUsuario = @CodUsuario and Cantidad <= 2 And Extraño = 0
		
		Set @Filas = @Filas +  @@RowCount

		UPDATE tCsApellidos
		Set  Extraño = 1, Referencia = @Usuario
		FROM tCsPadronClientes C
		WHERE C.ApeEsposo = tCsApellidos.Apellido
		AND   C.CodUsuario = @CodUsuario and Cantidad <= 2 And Extraño = 0
		
		Set @Filas = @Filas +  @@RowCount 		

		SELECT @Cadena = 'UPDATE tCsApellidos SET Referencia = tCsPadronClientes_1.NombreCompleto FROM tCsPadronClientes INNER JOIN tCsApellidos ON tCsPadronClientes.' + 
		                  CASE substring(MIN(Parametro),9, 1) WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + 
                         ' = tCsApellidos.Apellido INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario WHERE (tCsPadronClientes.' +
                          CASE substring(MIN(Parametro), 9, 1) WHEN 'P' THEN 'Paterno' WHEN 'M' THEN 'Materno' WHEN 'E' THEN 'ApeEsposo' END + ' = ''' + LTRIM(RTRIM(SUBSTRING(MIN(Parametro), 10, 50))) +
                         ''') AND (dbo.fduFechaATexto(tCsPadronClientes.FechaIngreso, ''AAAAMMDD'') = ''' + LEFT(MIN(Parametro), 8) + ''')' 
		FROM (
		    SELECT dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'P' + Apellido AS Parametro
            FROM (
                SELECT Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                FROM tCsPadronClientes 
                INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario 
                INNER JOIN (
                    SELECT tCsApellidos.Apellido
                    FROM tCsPadronClientes 
                    INNER JOIN tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
                    WHERE (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')
                ) Paterno ON tCsPadronClientes.Paterno = Paterno.Apellido
                GROUP BY Paterno.Apellido
            ) Datos
            UNION
            SELECT dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'M' + Apellido AS Parametro
            FROM (
                SELECT Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                FROM tCsPadronClientes 
                INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario 
                INNER JOIN (
                    SELECT tCsApellidos.Apellido
                    FROM tCsPadronClientes 
                    INNER JOIN tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
                    WHERE (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')
                ) Paterno ON tCsPadronClientes.Materno = Paterno.Apellido
                GROUP BY Paterno.Apellido
            ) Datos
            UNION
            SELECT dbo.fdufechaatexto(Ingreso, 'AAAAMMDD') + 'E' + Apellido AS Parametro
            FROM (
                SELECT Paterno.Apellido, MIN(tCsPadronClientes.FechaIngreso) AS Ingreso
                FROM tCsPadronClientes 
                INNER JOIN tCsPadronClientes tCsPadronClientes_1 ON tCsPadronClientes.CodUsResp = tCsPadronClientes_1.CodUsuario 
                INNER JOIN (
                    SELECT tCsApellidos.Apellido
                    FROM tCsPadronClientes 
                    INNER JOIN tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
                    WHERE (tCsPadronClientes.CodUsuario = @CodUsuario) AND (LTRIM(RTRIM(ISNULL(tCsApellidos.Referencia, ''))) = '')
                ) Paterno ON tCsPadronClientes.ApeEsposo = Paterno.Apellido
                GROUP BY Paterno.Apellido
            ) Datos
        ) Datos
		
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
	End
	If @Dato = 2
	Begin
		--Print '01'
		--Print GetDAte() 
		If	Len(@Dato2) >= 10 and Len(@Dato2) <= 13										And 
			Isnumeric(Left(@Dato2, 4)) = 0 And Isnumeric(Right(Left(@Dato2, 10),6)) = 1	And
			ltrim(rtrim(Isnull(@Dato1, ''))) <> ''	
		Begin		
			--Print 'RFC: ' + @Dato2
			--Print 'ENTRA PARA SER PROCESADO'
			--Set @CodUsuario = ''
			Set @Nacimiento = Null
			
			Select  @Nacimiento = FechaNacimiento from [10.0.2.14].Finmas.dbo.tUsUsuarios Where CodUsuario = @CodUsuario 
			--Print @Nacimiento
			If	Rtrim(Ltrim(Isnull(@CodUsuario, ''))) <> '' And
				dbo.fduFechaAtexto(@Nacimiento, 'AA') + 
				dbo.fduFechaAtexto(@Nacimiento, 'MM') +
				dbo.fduFechaAtexto(@Nacimiento, 'DD') = Right(Left(@Dato2, 10), 6)
			Begin
				Set @Cadena = 'UPDATE [10.0.2.14].Finmas.dbo.tUsUsuarios Set DI = ''' + @Dato2 + ''', '
				Set @Cadena = @Cadena + 'FechaReg = GetDate(), CodUsResp	= Case When Ltrim(Rtrim(Isnull('
				Set @Cadena = @Cadena + '''' + @CodUsuarioU + ''', ''''))) = '''' Then CodUsResp Else ''' 
				Set @Cadena = @Cadena + @CodUsuarioU + ''' End WHERE '
				Set @Cadena = @Cadena + '(CodDocIden = ''RFC'') And CodUsuario =''' +  @CodUsuario + ''''
				If @Calificacion = 2
				Begin
					Set @Cadena = 'UPDATE tSATExentasPadron Set CambiarOperativa = 1 Where CodUsuario = ''' + @CodUsuarioC + ''''
				End
				--Print @Cadena
				Exec (@Cadena)
				Set @Filas = @Filas +  @@RowCount  
				--Print '02'
				--Print GetDAte() 
				Set @Cadena = 'UPDATE [10.0.2.14].Finmas.dbo.tUsUsuarioSecundarios	Set UsRUC = ''' + @Dato2  
				Set @Cadena = @Cadena + ''' WHERE CodUsuario = ''' + @CodUsuario + '''' 
				If @Calificacion = 2
				Begin
					Set @Cadena = 'UPDATE tSATExentasPadron Set CambiarOperativa = 1 Where CodUsuario = ''' + @CodUsuarioC + ''''
				End
				--Print @Cadena
				Exec (@Cadena)
				Set @Filas = @Filas +  @@RowCount  
				--Print '03'
				--Print GetDAte()
				If @Filas > 0
				Begin
					--Print 'RFC BUENO : ' +  @Dato2
					Update tCsPadronClientes 
					Set UsRFC = @Dato2
					WHERE CodUsuario = @CodUsuarioC
					Update tCsPadronClientes 
					Set DI = @Dato2
					WHERE CodUsuario = @CodUsuarioC And CodDocIden = 'RFC'
				End		
				--Print '04'
				--Print GetDAte()	
			End			
		End		
	End	
End
If @Filas = 0
Begin
	DELETE FROM tCsFirmaElectronica WHERE Firma = @Firma
End
Else
Begin
	If @Dato = 1
	Begin		
		Set @Cadena = '07'
	End
	If @Dato = 2
	Begin
		Set @Cadena = '13'
	End
	--Print '05'
	--Print GetDAte()
	If @Calificacion = 1
	Begin
		--Print 'Se procede a Calificar la Agencia'
		--Print GetDate()
		Create Table #Agencia
		(CodOficina Varchar(4))
		
		Insert Into #Agencia
		Select Distinct CodOficina from (
		Select OORigen As CodOFicina From tcsclientesobservaciones
		Where Observacion = @Cadena And CodUsuario = @CodUsuarioC And Fecha = @Fecha
		Union 
		Select OAhorros As CodOFicina From tcsclientesobservaciones
		Where Observacion = @Cadena And CodUsuario = @CodUsuarioC And Fecha = @Fecha
		Union 
		Select OCreditos As CodOFicina From tcsclientesobservaciones
		Where Observacion = @Cadena And CodUsuario = @CodUsuarioC And Fecha = @Fecha) Datos
		
		Delete From tcsclientesobservaciones Where Observacion = @Cadena And CodUsuario = @CodUsuarioC And Fecha = @Fecha
		Declare curFragmento1 Cursor For 
			Select CodOficina from #Agencia
		Open curFragmento1
		Fetch Next From curFragmento1 Into @CodOficina
		While @@Fetch_Status = 0
		Begin 
			Exec pCsClientesObservacion @CodOficina, 'TODAS', 4 
		Fetch Next From curFragmento1 Into @CodOficina
		End 
		Close 		curFragmento1
		Deallocate 	curFragmento1
		--Print Getdate()
	End	
	--Print '06'
	--Print GetDAte()
End
------------------------------------
--SECCION: DATOS PARA EL REPORTE
------------------------------------
--Exec pCsFrase @Cadena Out		

If @Calificacion <> 2
Begin 
	SELECT Proceso = @Proceso, Firma = @Firma, Usuario = @Usuario, * , Frase = @Cadena
	FROM	(
	SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto, Tipo = '01 Ap. Paterno', Dato = Apellido, 
		   Case tCsApellidos.Extraño 	When 1 Then 'Si' Else 'No' End As Observado, 
		   Case tCsApellidos.Verificado When 1 Then 'Si' Else 'No' End As Verificado, 
			   tCsApellidos.Registro, tCsApellidos.Cantidad, Isnull(tCsApellidos.Referencia, 'Ninguna') as Referencia
	FROM         tCsPadronClientes INNER JOIN
						  tCsApellidos ON tCsPadronClientes.Paterno = tCsApellidos.Apellido
	WHERE     (tCsPadronClientes.CodUsuario = @CodUsuarioC)
	UNION
	SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto, Tipo = '02 Ap. Materno', Dato = Apellido, 
		   Case tCsApellidos.Extraño 	When 1 Then 'Si' Else 'No' End As Observado, 
		   Case tCsApellidos.Verificado When 1 Then 'Si' Else 'No' End As Verificado, 
			   tCsApellidos.Registro, tCsApellidos.Cantidad, Isnull(tCsApellidos.Referencia, 'Ninguna') as Referencia
	FROM         tCsPadronClientes INNER JOIN
						  tCsApellidos ON tCsPadronClientes.Materno = tCsApellidos.Apellido
	WHERE     (tCsPadronClientes.CodUsuario = @CodUsuarioC)
	UNION
	SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto, Tipo = '03 Ap. Conyuge', Dato = Apellido, 
		   Case tCsApellidos.Extraño 	When 1 Then 'Si' Else 'No' End As Observado, 
		   Case tCsApellidos.Verificado When 1 Then 'Si' Else 'No' End As Verificado, 
			   tCsApellidos.Registro, tCsApellidos.Cantidad, Isnull(tCsApellidos.Referencia, 'Ninguna') as Referencia
	FROM         tCsPadronClientes INNER JOIN
						  tCsApellidos ON tCsPadronClientes.ApeEsposo = tCsApellidos.Apellido
	WHERE     (tCsPadronClientes.CodUsuario = @CodUsuarioC)
	UNION
	SELECT        @CodUsuarioC AS CodUsuario, tCsPadronClientes.NombreCompleto, '04 RFC Malo' AS Tipo, 
							 CASE WHEN tCsPadronClientes.UsRFCVal = 0 THEN tCsPadronClientes.UsRFC ELSE 'EL RFC ESTA BIEN' END AS Dato, 
							 CASE WHEN tCsPadronClientes.UsRFCVal = 0 THEN 'Si' ELSE 'No' END AS Observado, 'No' AS Verificado, tCsPadronClientes.FechaIngreso, 1 AS Cantidad, 
							 tCsPadronClientes_1.NombreCompleto AS Referencia
	FROM            tCsPadronClientes AS tCsPadronClientes_1 RIGHT OUTER JOIN
							 tCsPadronClientes ON tCsPadronClientes_1.CodUsuario = tCsPadronClientes.CodUsResp
	WHERE        (tCsPadronClientes.CodUsuario = @CodUsuarioC)
	Union
	SELECT        @CodUsuarioC AS CodUsuario, tCsPadronClientes.NombreCompleto, '05 RFC Bueno' AS Tipo, 
							 CASE WHEN tCsPadronClientes.UsRFCVal = 1 THEN tCsPadronClientes.UsRFC ELSE tCsPadronClientes.UsRFCBD END AS Dato, 'No' AS Observado, 
							 'No' AS Verificado, tCsPadronClientes.FechaIngreso, 1 AS Cantidad, 
							 CASE WHEN tCsPadronClientes.UsRFCVal = 1 THEN tCsPadronClientes_1.NombreCompleto ELSE '' END AS Referencia
	FROM            tCsPadronClientes AS tCsPadronClientes_1 RIGHT OUTER JOIN
							 tCsPadronClientes ON tCsPadronClientes_1.CodUsuario = tCsPadronClientes.CodUsResp
	WHERE        (tCsPadronClientes.CodUsuario = @CodUsuarioC)
	) Datos
End	
--Print '07'
--Print GetDAte()

GO