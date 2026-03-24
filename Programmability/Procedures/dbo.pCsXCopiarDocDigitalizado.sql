SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXCopiarDocDigitalizado](@RutaArchivo varchar(150)) as
BEGIN
	SET NOCOUNT ON;

	declare @comando varchar(350)
	declare @pathOrigen varchar(150)
	declare @pathDestino varchar(150)
	declare @archivo varchar(50)
	
	set @pathOrigen = @RutaArchivo -- '\\10.0.2.17\\EventoEvidencia\\8\\SOL-0004277_133007.pdf'
	set @pathOrigen = replace(@pathOrigen,'\\\\','\\')
	set @pathOrigen = replace(@pathOrigen,'\\','\') --quita el doble \\
	--select @pathOrigen
	set @pathOrigen = '\' + @pathOrigen  --le pone un \ al principio
	--select @pathOrigen
	
	--EXTRAE SOLO EL NOMBRE DEL ARCHIVO
	set @archivo = reverse( @pathOrigen)
	--select @archivo
	--select charindex('\',@archivo, 0)
	set @archivo = left(@archivo,(charindex('\',@archivo, 0)-1))
	set @archivo = reverse( @archivo)
	--select @archivo 
	set @pathDestino = '\\10.0.2.10\DocsDigCompartidos\' + rtrim(@archivo)
	--select @pathDestino
	
	set @comando = 'copy "' + @pathOrigen + '" "' + @pathDestino + '" /Y'
	
	print @comando
	
	
	
	--select @comando
	select 'http://200.57.187.212/DocsDigCompartidos/' + rtrim(@archivo) as 'RutaDescarga'
	
	
	
	exec master..xp_cmdshell "net use t: \\10.0.2.17\EventoEvidencia  /persistent:yes";
	exec master..xp_cmdshell "net use r: \\10.0.2.10\DocsDigCompartidos 17#ti$FA /user:Administrador";
	
	-- net use unidad: \\servidor\recurso compartido password /User
	
	--exec master..xp_cmdshell "net use t: \\10.0.2.17\EventoEvidencia /user:Administrador /persistent:yes";
	--exec master..xp_cmdshell "net use r: \\10.0.2.10\DocsDigCompartidos 1002 /user:Adminitrador /persistent:yes";
	
	EXEC master.dbo.xp_cmdshell @comando;
	
	EXEC master..xp_cmdshell "net use t: /delete";
	EXEC master..xp_cmdshell "net use r: /delete";
	
	
END
GO