SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCREnvioCorreo]
@Empresa		Varchar(100),
@CC			Varchar(200),
@CCPredefinido		Bit,
@IPConsolidado		Varchar(50),
@BaseConsolidado	Varchar(50)
As
--Set @Empresa		= 'BURO DE CREDITO'
--Set @CC		= 'kvalera@financierafinamigo.com.mx; eburgos@financierafinamigo.com.mx; hguzman@financierafinamigo.com.mx'
--Set @CCPredefinido	= 1
--Set @IpConsolidado	= '10.0.1.13'
--Set @BaseConsolidado	= 'FinamigoConsolidado'

Declare @Asunto 	Varchar(1000)
Declare @Correo 	Varchar(50)
Declare @Para		Varchar(4000)
Declare @Mensaje	Varchar(4000)
Declare @Top		Int
Declare @Cadena		Varchar(4000)
Declare @Frase		Varchar(4000)
Declare @Firma		Varchar(4000)
Declare @Asignado	Varchar(100)
Declare @Usuario	Varchar(100)
Declare @Contraseña	Varchar(10)
Declare @Caducidad	SmallDateTime
Declare @CopiaCorreo	Varchar(500)
Declare @Temporal	Varchar(500)
Declare @Consulta	SmallDateTime
Declare @Consolidado	Varchar(100)
Declare @Servidor	Varchar(100)

Set @Servidor = @IpConsolidado  
Set @Asunto		= 'Usuario y Contraseña de ' + @Empresa

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[B] End
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

Set @Temporal	= Ltrim(Rtrim(@CC))
Set @Firma 	= 'Atte.' + Char(13)
Set @Firma 	= @Firma + 'Ing. Kemy Valera Valles' + Char(13)
Set @Firma 	= @Firma + 'Dpto. de Proyectos y Desarrollo' + Char(13)
Set @Firma 	= @Firma + 'Area de Sistemas' + Char(13)
Set @Firma 	= @Firma + 'Financiera Mexicana para el Desarrollo Rural' + Char(13)
Set @Firma 	= @Firma + 'Insurgentes Sur Nº. 1844 2º Piso' + Char(13)
Set @Firma 	= @Firma + 'Col. Florida.' + Char(13)
Set @Firma 	= @Firma + 'Del. Álvaro Obregón C.P. 01030' + Char(13)
Set @Firma 	= @Firma + '56616978 Ext. 164 Cel: 5529898953' + Char(13) + Char(13) 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CentralRiesgos]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[CentralRiesgos] End

CREATE TABLE [dbo].[CentralRiesgos] (
	[Correo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[AsignadoFinamigo] [varchar] (300) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[ClaveOtorgante] [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Contraseña] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[Expira] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[CopiaCorreo] [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,
	[Consulta] [datetime] NULL 
) ON [PRIMARY]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Frase]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[Frase] End

CREATE TABLE [dbo].[Frase] (
	[Frase] [varchar] (4000) COLLATE Modern_Spanish_CI_AI NULL 
) ON [PRIMARY]

Set @Cadena = 'INSERT INTO CentralRiesgos '
Set @Cadena = @Cadena  + 'SELECT tCRUsuarios.Correo, ISNULL(tCsPadronClientes.NombreCompleto, ''No Especificado'') AS AsignadoFinamigo, tCREmpresaUsuarios.ClaveOtorgante, '
Set @Cadena = @Cadena  + 'tCREmpresaUsuarios.Contraseña, dbo.fduFechaATexto(tCREmpresaUsuarios.Expira - 1, ''AAAAMMDD'') AS Expira, tCRUsuarios.CopiaCorreo, '
Set @Cadena = @Cadena  + 'tCREmpresaUsuarios.Consulta '
Set @Cadena = @Cadena  + 'FROM '+ @Servidor + @BaseConsolidado + '.dbo.tCsPadronClientes tCsPadronClientes RIGHT OUTER JOIN '
Set @Cadena = @Cadena  + @Servidor + @BaseConsolidado + '.dbo.tCRUsuarios tCRUsuarios ON tCsPadronClientes.CodUsuario = tCRUsuarios.CodUsuario RIGHT OUTER JOIN '
Set @Cadena = @Cadena  + @Servidor + @BaseConsolidado + '.dbo.tCREmpresaUsuarios tCREmpresaUsuarios ON tCRUsuarios.CodUsuario = tCREmpresaUsuarios.CodUsuario '
Set @Cadena = @Cadena  + 'WHERE (tCREmpresaUsuarios.EnviaCorreo = 1) '

Exec (@Cadena)

Declare curUsuario Cursor For 
Select 	* 
From 	CentralRiesgos
Open curUsuario
Fetch Next From curUsuario Into @Correo, @Asignado, @Usuario, @Contraseña, @Caducidad, @CopiaCorreo, @Consulta
While @@Fetch_Status = 0
Begin
	Set @Para 	= ''	
	Set @CC		= @Temporal
	Set @Para 	= @Para +'; ' + RTrim(Ltrim(@Correo))

	Set @Cadena = 'Declare @Frase Varchar(4000) ' + Char(13) + 'Exec ' + @Servidor + @BaseConsolidado + '.dbo.pCsFrase @Frase Out' + char(13) +  'Insert Into Frase Values(@Frase)'
	Exec (@Cadena)

	Select @Frase = Frase From Frase 

	Set @Cadena = 'Update '+ @Servidor + @BaseConsolidado + '.dbo.tCsFrase Set Aleatorio = 1 Where Aleatorio = 2 '
	Exec (@Cadena)
	
	If isnull(Ltrim(RTrim(@CopiaCorreo)), '') <> '' And @CCPredefinido = 1
	Begin
	Set @CC = @CC + '; ' + @CopiaCorreo
	End

	Set @Para = Rtrim(Ltrim(SubString(@Para, 3, 4000)))
	Print 'Para : ' + @Para
	Print 'Copia: ' + @CC	

	Set @Mensaje ='Buen día '+ LTRIM(RTRIM(@Asignado)) +' por el presente informarte que:'+ Char(13) + Char(13)
	Set @Mensaje = @Mensaje + 'Tu usuario de '+ @Empresa +' es: ' + @Usuario + Char(13) 
	Set @Mensaje = @Mensaje + 'Tu Contraseña de '+ @Empresa +' es: ' + @Contraseña + Char(13)
	Set @Mensaje = @Mensaje + 'La fecha de Caducidad es: '+ Cast(@Caducidad as Varchar(100))  + Char(13) + Char(13)
	Set @Mensaje = @Mensaje + 'No olvidarse que deben cambiar la contraseña e informar a los siguientes correos: kvalera@financierafinamigo.com.mx y eburgos@financierafinamigo.com.mx la nueva contraseña y la nueva fecha de caducidad.' + Char(13) + Char(13)
		
	--Set @Mensaje = @Mensaje + @Para + Char(13)
	--Set @Mensaje = @Mensaje + @CC + Char(13)	

	Set @Mensaje = @Mensaje + 'Frase para meditar: ' + Char(13) 
	Set @Mensaje = @Mensaje + @Frase + Char(13) + Char(13)
	
	Set @Mensaje = @Mensaje + 'Quedando de ustedes, me despido.' + Char(13) + Char(13)
	Set @Mensaje = @Mensaje + @Firma

	Set @Mensaje = @Mensaje + 'PD: - Este Correo fue generado automáticamente.' + Char(13)
	Set @Mensaje = @Mensaje + 'PD: - La clave de '+ @Empresa +' debes cambiar antes de la fecha de caducidad.' + Char(13)
	
	EXEC dbo.xp_sendmail 
		@recipients 		= @Para, 
	   	--@query 		= '',
	   	@subject 		= @Asunto,
	   	@message 		= @Mensaje,
	   	@copy_recipients 	= @CC	
	   	--@attach_results 	= 'TRUE', @width = 250

Fetch Next From curUsuario Into  @Correo, @Asignado, @Usuario, @Contraseña, @Caducidad, @CopiaCorreo, @Consulta
End 
Close 		curUsuario
Deallocate 	curUsuario

GO