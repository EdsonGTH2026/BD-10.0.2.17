SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsXCopiarFotoWebAEvidenciasAH] (@ArchivoOrigen varchar(50), @CodCuenta varchar(20), @IdTipoDocumento int, @Resultado varchar(10) output)
as
BEGIN
	set nocount off
	
	--copiar foto subida x ws a ruta general para todas las evidencias
	--<<<<<<<< COMENTAR
	/*
	declare @ArchivoOrigen varchar(50)
	declare @CodOficina varchar(3)
	set @ArchivoOrigen = 'CompDom(SOL-0015928)(4).jpg'
	set @CodOficina = '4'
	*/
	-->>>>>>>> COEMNTAR

	--extrae el codigo de la oficina de la cuenta de ahorro
	declare @codoficina varchar(3)
	set @codoficina = left(@codcuenta,3)
	select @codoficina = convert(varchar(3),convert(int, @codoficina )) 

	declare @RutaOrigen varchar(100)
	declare @RutaArchivoOrigen varchar(150)
	declare @RutaDestino varchar(100)
	declare @RutaArchivoDestino varchar(150)
	declare @Servidor varchar(50)
	declare @Ruta varchar(50)
	declare @comando varchar(200)
	--declare @Copiado bit
	
	set @Resultado = ''
	set @RutaOrigen = '\\10.0.2.9\Storage' --Directorio compartido en donde se suben los archivos por el WS
	set @RutaArchivoOrigen = @RutaOrigen + '\' + @ArchivoOrigen
	
	select @Servidor = Valor from [10.0.2.14].finmas.dbo.tcaEventoConfig where opcion = 'Servidor'
	select @Ruta =Valor from [10.0.2.14].finmas.dbo.tcaEventoConfig where opcion = 'Ruta'
	
	set @RutaDestino = @Servidor + @Ruta + '' +  @CodOficina
	set @RutaDestino = replace(@RutaDestino,'\\\\','\\')
	set @RutaDestino = replace(@RutaDestino,'\\','\') --quita el doble \\
	set @RutaDestino = '\' + @RutaDestino  --le pone un \ al principio
	
	set @RutaArchivoDestino = @RutaDestino  + '\' + @ArchivoOrigen
	set @RutaArchivoDestino = replace(@RutaArchivoDestino,'\\\\','\\')
	set @RutaArchivoDestino = replace(@RutaArchivoDestino,'\\','\') --quita el doble \\
	set @RutaArchivoDestino = '\' + @RutaArchivoDestino  --le pone un \ al principio
	
	--select @RutaArchivoOrigen as '@RutaArchivoOrigen'  --comentar
	--select @RutaArchivoDestino as '@RutaArchivoDestino'  --comentar
	
	set @comando = 'copy "' + @RutaArchivoOrigen + '" "' + @RutaArchivoDestino + '"'
	--select @comando as '@comando' --comentar
	
	declare @t varchar(100)
	declare @r varchar(100)
	
	set @t = '"net use t: ' + @RutaOrigen + ' 1002 /user:finamigo\soporte /persistent:yes"'
	set @r = '"net use r: ' + @RutaDestino + ' 1002 /user:finamigo\soporte /persistent:yes"'
	--select @t as '@t' --comentar
	--select @r as '@r' --comentar
	exec master..xp_cmdshell @t;  --"net use t: \\10.0.2.17\EventoEvidencia 1002 /user:finamigo\soporte /persistent:yes";
	exec master..xp_cmdshell @r;  --"net use r: \\10.0.2.9\DocsDigCompartidos 1002 /user:finamigo\soporte /persistent:yes";
	
	EXEC master.dbo.xp_cmdshell @comando;
	
	--verifica que se haya copiado archivo
	DECLARE @result INT
	EXEC master.dbo.xp_fileexist @RutaArchivoDestino, @result OUTPUT
	--select @result as '@result'
	--select @Copiado = cast(@result as bit)
	
	EXEC master..xp_cmdshell "net use t: /delete";
	EXEC master..xp_cmdshell "net use r: /delete";

	--Si el archivo fue copiado correctamente, entonces invoca al sp para registrar en la tabla de
	--EventoEvidencia

	if @result = 1
	begin
		--ejecuta el sp

		set @RutaArchivoDestino = replace(@RutaArchivoDestino,'\','\\')
		set @RutaArchivoDestino = replace(@RutaArchivoDestino,'\\\\','\\')

		--exec pCsXRegistrarEvidencia '4', 'SOL-0015928','curbiza','c:\temp', 'comprobante dom.jpg', '\\10.0.2.17\\EventoEvidencia2\\4\\SOL-0015928_125900.jpg', 'SOL-0015928_125900.jpg', 7
		--exec pCsXRegistrarEvidencia @CodOficina, @CodSolicitud,'curbiza',@RutaOrigen, @ArchivoOrigen, @RutaArchivoDestino, @ArchivoOrigen, @IdTipoDocumento, @Resultado output

        --exec pCaXRegistrarEvidenciaAH '098-111-06-1-3-00334','curbiza','c:\temp', 'comprobante dom.jpg', '\\10.0.2.17\\EventoEvidencia2\\4\\SOL-0015928_125900.jpg', 'SOL-0015928_125901.jpg', 16, @result output
                                 --pCaXRegistrarEvidenciaAH (@codcuenta, @LogUsuario, @RutaOriginal,@NombreOriginal, @RutaDestino, @NombreNuevo, @IdTipoDocumento, @Resultado varchar(10) output)
        exec [10.0.2.14].finmas.dbo.pCaXRegistrarEvidenciaAH @CodCuenta, 'curbiza', @RutaOrigen, @ArchivoOrigen, @RutaArchivoDestino, @ArchivoOrigen, @IdTipoDocumento, @Resultado output
		--set @Resultado = 'OK'

	end
	else
	begin 
		set @Resultado = 'ERROR'
		--manda error
		RAISERROR ('Error al copiar el archivo.' , 16,-1)
		RETURN 
	end

	select @Resultado as 'Resultado'
END

GO