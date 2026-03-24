SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsXRegistrarEvidencia](@codoficina varchar(3),@codsolicitud varchar(20),@LogUsuario varchar(20),@RutaOriginal varchar(150),@NombreOriginal varchar(50),@RutaDestino varchar(150),@NombreNuevo varchar(50),@IdTipoDocumento int,  @Resultado varchar(10) output) 
as
BEGIN
	--PRODUCCION
	 exec [10.0.2.14].finmas.dbo.pCaXRegistrarEvidencia @codoficina, @codsolicitud, @LogUsuario, @RutaOriginal, @NombreOriginal, @RutaDestino, @NombreNuevo, @IdTipoDocumento, @Resultado output   
	--PRUEBAS
	--exec [10.0.2.14].finmas_20190107fin.dbo.pCaXRegistrarEvidencia @codoficina, @codsolicitud, @LogUsuario, @RutaOriginal, @NombreOriginal, @RutaDestino, @NombreNuevo, @IdTipoDocumento, @Resultado output   
	--exec [10.0.2.14].finmas_20190315ini.dbo.pCaXRegistrarEvidencia @codoficina, @codsolicitud, @LogUsuario, @RutaOriginal, @NombreOriginal, @RutaDestino, @NombreNuevo, @IdTipoDocumento, @Resultado output   
END
GO