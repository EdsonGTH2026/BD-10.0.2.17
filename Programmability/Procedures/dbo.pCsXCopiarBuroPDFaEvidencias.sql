SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsXCopiarBuroPDFaEvidencias] (@RutaArchivoOrigen varchar(150), @CodOficina varchar(3), @CodSolicitud varchar(20), @IdTipoDocumento int, @Resultado varchar(10) output)
as
BEGIN
	set nocount off
	
	--copiar PDF de Buro de Credito a ruta general para todas las evidencias

	--<<<<<<<< COMENTAR
	/*
	declare @RutaArchivoOrigen varchar(50)
	declare @CodOficina varchar(3)
	set @RutaArchivoOrigen = 'CompDom(SOL-0015928)(4).jpg'
	set @CodOficina = '4'
	*/
	-->>>>>>>> COEMNTAR
	
	declare @RutaOrigen varchar(100)
	declare @ArchivoOrigen varchar(50)
	declare @RutaArchivoOrigen2 varchar(150)
	declare @RutaDestino varchar(100)
	declare @RutaArchivoDestino varchar(150)
	declare @Servidor varchar(50)
	declare @Ruta varchar(50)
	declare @comando varchar(200)
	--declare @Copiado bit

	--Quita las diagonales dobles
	set @RutaArchivoOrigen = replace(@RutaArchivoOrigen,'\\\\','\\')
	set @RutaArchivoOrigen = replace(@RutaArchivoOrigen,'\\','\') --quita el doble \\
	
	
	--EXTRAE SOLO EL NOMBRE DEL ARCHIVO
	set @ArchivoOrigen = reverse( @RutaArchivoOrigen)
	--select @ArchivoOrigen
	--select charindex('\',@ArchivoOrigen, 0)
	set @ArchivoOrigen = left(@ArchivoOrigen,(charindex('\',@ArchivoOrigen, 0)-1))
	set @ArchivoOrigen = reverse( @ArchivoOrigen)
	--select @ArchivoOrigen 


	set @Resultado = ''

	--Directorio compartido en donde se suben los archivos por el WS
	--set @RutaOrigen = '\\10.0.2.17\bc\Monitor'
	set @RutaOrigen = '\\10.2.3.40\AppPDF'
	--set @RutaOrigen = '\\10.0.2.14\buro\PDF'
	set @RutaArchivoOrigen2 = @RutaOrigen + '\' + @ArchivoOrigen
	
	select @Servidor = Valor from [10.0.2.14].finmas.dbo.tcaEventoConfig where opcion = 'Servidor'
	select @Ruta =Valor from [10.0.2.14].finmas.dbo.tcaEventoConfig where opcion = 'Ruta'
	--select @Servidor = Valor from finmas.dbo.tcaEventoConfig where opcion = 'Servidor'
	--select @Ruta =Valor from finmas.dbo.tcaEventoConfig where opcion = 'Ruta'
	
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
	
	set @comando = 'copy "' + @RutaArchivoOrigen2 + '" "' + @RutaArchivoDestino + '"'
	select @comando as '@comando' --comentar
	
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

		--print '@RutaArchivoOrigen = ' + @RutaArchivoOrigen 
		--print '@ArchivoOrigen = ' + @ArchivoOrigen 
		--print '@RutaArchivoDestino = ' + @RutaArchivoDestino
		--exec pCsXRegistrarEvidencia '4', 'SOL-0015928','curbiza','c:\temp', 'comprobante dom.jpg', '\\10.0.2.17\\EventoEvidencia2\\4\\SOL-0015928_125900.jpg', 'SOL-0015928_125900.jpg', 7
		exec pCsXRegistrarEvidencia @CodOficina, @CodSolicitud,'curbiza',@RutaArchivoOrigen2, @ArchivoOrigen, @RutaArchivoDestino, @ArchivoOrigen, @IdTipoDocumento, @Resultado output
		set @Resultado = 'OK'

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