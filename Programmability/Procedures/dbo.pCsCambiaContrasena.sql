SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCambiaContrasena]
@Usuario Varchar(50), @Correo Varchar(1000), @Contraseña	Varchar(6), @Sistema Varchar(100), @Empresa Varchar(100), @Giro Varchar(100), @Duplicadas Bit
As
--Declare @Usuario Varchar(50), @Correo Varchar(100), @Contraseña	Varchar(6), @Sistema Varchar(100), @Empresa Varchar(100), @Giro Varchar(100)
--Declare @Duplicadas Bit

--Set	@Usuario 	= 'kvalera' 
--Set 	@Correo 	= 'ssanchezl@finamigo.com.mx'
--Set 	@Contraseña	= '420801'
--Set 	@Duplicadas	= 1

-----------------DATOS FIJOS-----------------0000
--Set 	@Sistema 	= 'DATANEGOCIO'
--Set	@Empresa	= 'FINAMIGO' 
--Set 	@Giro		= 'Sociedad Financiera Popular'
---------------------------------------------0000
--Declare @Version	Int
--SELECT  @Version = CAST(SUBSTRING(CAST(SERVERPROPERTY('productversion') AS Varchar(10)), 1, CHARINDEX('.', CAST(SERVERPROPERTY('productversion') AS Varchar(10)), 1) - 1) AS Int) 

If IsNumeric(@Usuario) = 1
Begin	
	Select @Usuario = max(Usuario) from tsgusuarios 
	Where contrasena = dbo.fduMD5(dbo.fduMD5(@Usuario)) --And Activo = 1	
End

Declare @NombreCompleto Varchar(100)
Declare @Activo		Varchar(2)
Declare @Oficina	Varchar(50)
Declare @Todas		Varchar(2)
Declare @Perfil		Varchar(50)

Declare @MD5		Varchar(100)
Declare @Mensaje	Varchar(8000)

SELECT  @Usuario 		= tSgUsuarios.Usuario, 
		@NombreCompleto = tSgUsuarios.NombreCompleto, 
		@Activo			= CASE tSgUsuarios.Activo WHEN 1 THEN 'SI' WHEN 0 THEN 'NO' END, 
		@Oficina		= tClOficinas.NomOficina, 
		@Todas			= CASE TodasOficinas WHEN 1 THEN 'SI' WHEN 0 THEN 'NO' END, 
		@Perfil 		= tSgGrupos.Grupo
FROM         tClOficinas RIGHT OUTER JOIN
                      tSgUsuarios LEFT OUTER JOIN
                      tSgUsSistema INNER JOIN
                      tSgGrupos ON tSgUsSistema.CodGrupo = tSgGrupos.CodGrupo ON tSgUsuarios.Usuario = tSgUsSistema.Usuario ON 
                      tClOficinas.CodOficina = tSgUsuarios.CodOficina
WHERE     (tSgUsuarios.Usuario = @Usuario)

If rtrim(ltrim(Isnull(@Contraseña, '')))= ''
Begin
	SELECT @Contraseña = Left(Cast(cast(RAND(datepart(millisecond, getdate())) * 1000000000 as Int)  % 1000 as Varchar(10)) +
		Cast(cast(RAND(datepart(second, getdate())) * 1000000000 as Int)  % 1000 as Varchar(10)) + 
		Cast(cast(RAND(datepart(Minute, getdate())) * 1000000000 as Int)  % 1000 as Varchar(10)), 6)
End

Select @MD5 = dbo.fduMD5(dbo.fduMD5(@Contraseña))
/*--Select @MD5 = HashBytes('MD5', HashBytes('MD5', @Contraseña))	*/

Update tSgUsuarios Set Activo = 1, Contrasena = @MD5 where Usuario = @Usuario
If @@RowCount = 1
Begin

	UPDATE    tSgUsuarios
	SET       Activo = tCsEmpleados.Estado
	FROM      tSgUsuarios INNER JOIN
			  tCsEmpleados ON tSgUsuarios.CodUsuario = tCsEmpleados.CodUsuario

	SELECT  @Usuario 		= tSgUsuarios.Usuario, 
			@NombreCompleto = tSgUsuarios.NombreCompleto, 
			@Activo			= CASE tSgUsuarios.Activo WHEN 1 THEN 'SI' WHEN 0 THEN 'NO' END, 
			@Oficina		= tClOficinas.NomOficina, 
	        @Todas			= CASE TodasOficinas WHEN 1 THEN 'SI' WHEN 0 THEN 'NO' END, 
			@Perfil 		= tSgGrupos.Grupo
	FROM	tClOficinas RIGHT OUTER JOIN
	                      tSgUsuarios LEFT OUTER JOIN
	                      tSgUsSistema INNER JOIN
	                      tSgGrupos ON tSgUsSistema.CodGrupo = tSgGrupos.CodGrupo ON tSgUsuarios.Usuario = tSgUsSistema.Usuario ON 
	                      tClOficinas.CodOficina = tSgUsuarios.CodOficina
	WHERE     (tSgUsuarios.Usuario = @Usuario)
End

Set @Mensaje = 'Saludos ' + @NombreCompleto + '; ' + Char(10)
Set @Mensaje = @Mensaje + char(10)
Set @Mensaje = @Mensaje + 'Por este medio se te notifica que tienes una nueva contraseña del '+ @Sistema +'.'+ Char(10)
Set @Mensaje = @Mensaje + 'Por favor se debe tener las siguientes consideraciones en la administración de sus contraseñas o claves: '+ Char(10)
Set @Mensaje = @Mensaje + 'Las contraseñas son una de las partes más importantes de los sistemas de información de una empresa. Una mala contraseña puede provocar robo de información, daños, etc.; en empresas donde la información es de vital importancia como '+ @Empresa +' por tratarse de una '+ @Giro +'.' + Char(10)
Set @Mensaje = @Mensaje + 'La contraseña proporcionada es una autorización para trabajar en el sistema '+ @Sistema +', una mala contraseña no solo puede llevar a robo o pérdidas sino a responsabilidad legal frente a terceros. “Por lo tanto recuerde que su contraseña es intransferible”.' + char(10)
Set @Mensaje = @Mensaje + char(10)
Set @Mensaje = @Mensaje + 'La contraseña debe tener las siguientes características para el '+ @Sistema +': ' + char(10)
Set @Mensaje = @Mensaje + char(10)
Set @Mensaje = @Mensaje + '1.	Debe estar compuesto por 6 números.' + char(10)
Set @Mensaje = @Mensaje + '2.	Se debe cambiar con frecuencia. ' + char(10)
Set @Mensaje = @Mensaje + '3.	Una contraseña nueva debe diferir considerablemente de la anterior.' + char(10)
Set @Mensaje = @Mensaje + char(10)
Set @Mensaje = @Mensaje + 'Para evitar problemas de usufructo con sus contraseñas debe tener en cuenta lo siguiente:' + char(10)
Set @Mensaje = @Mensaje + '1.	Nunca uses tu fecha de cumpleaños, número nacional de identificación, o números secuenciales' + char(10)
Set @Mensaje = @Mensaje + '2.	No uses la misma contraseña para todos Sistemas que se tiene en '+ @Empresa +'.' + char(10)
Set @Mensaje = @Mensaje + '3.	Nunca escribas tus contraseñas en pedazos de papel.'
Set @Mensaje = @Mensaje + char(10)
Set @Mensaje = @Mensaje + '---------------------------------------------------------' + Char(10)
Set @Mensaje = @Mensaje + 'Usuario			: ' + @Usuario + Char(10)
Set @Mensaje = @Mensaje + 'Nombre			: ' + @NombreCompleto + Char(10)
Set @Mensaje = @Mensaje + 'Perfil				: ' + @Perfil + Char(10)
Set @Mensaje = @Mensaje + 'Oficina Predeterminada	: ' + @Oficina + Char(10)
Set @Mensaje = @Mensaje + 'Accesos a demás Oficinas	: ' + @Todas + Char(10)
Set @Mensaje = @Mensaje + 'Activo				: ' + @Activo + Char(10)
Set @Mensaje = @Mensaje + 'Contraseña			: ' + @Contraseña + Char(10)
Set @Mensaje = @Mensaje + '---------------------------------------------------------'

Print @Mensaje
Select @Mensaje as Mensaje

Declare @Hora 	varchar(15)
Declare @Fecha 	Varchar(8)

Set @Fecha 	= dbo.fdufechaatexto(getdate(), 'AAAAMMDD')
Set @Hora	= CONVERT(VARCHAR(20), GETDATE(), 114)
Set @Correo	= LTrim(Rtrim(@Correo))

If Not ((Ascii(Right(@Correo,1)) >= 65 And Ascii(Right(@Correo,1)) <= 90) OR (Ascii(Right(@Correo,1)) >= 97 And Ascii(Right(@Correo,1)) <= 122))
Begin
	Set @Correo = Left(@Correo, len(@Correo)- 1)
End

If ltrim(rtrim(Isnull(@Mensaje, ''))) <> '' And Ltrim(rtrim(@Correo)) <> '' And CharIndex('@', @Correo, 1) > 1 And CharIndex('.', @Correo, 1) > 2 
Begin
	Set @Mensaje = 'Cambio de Contraseña '+ @Sistema +'|' + REplace(@Mensaje, Char(10), '<BR>')
	Exec pSgInsertaEnColaServicio 'DN',3, @Correo,@Fecha,@Hora,@Mensaje
	
End
Else
Begin
	Print 'No se envío ningun correo, revise si esta bien escrito'
End



If @Duplicadas = 1
Begin
	SELECT        isnull(tCsEmpleados.CodOficina, tSgUsuarios_1.CodOficina) as CodOficina, tSgUsuarios_1.Usuario, tSgUsuarios_1.NombreCompleto,  
	                          tCsEmpleados.Correo, tCsEmpleados.Estado, 'Cambiar Contraseña,se repite con otro Usuario' AS Accion
	FROM            (SELECT        Contrasena, COUNT(*) AS Contador
	                          FROM            tSgUsuarios
	                          WHERE        (Activo = 1)
	                          GROUP BY Contrasena
	                          HAVING         (COUNT(*) > 1)) AS Filtro INNER JOIN
	                         tSgUsuarios AS tSgUsuarios_1 ON Filtro.Contrasena = tSgUsuarios_1.Contrasena LEFT OUTER JOIN
	                         tCsEmpleados ON tSgUsuarios_1.CodUsuario = tCsEmpleados.CodUsuario
End

GO