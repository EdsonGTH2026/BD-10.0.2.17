SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXObtieneDocDigitalizadoByTipo](@codsolicitud varchar(20), @codoficina varchar(3), @IdTipoDocumento int) 
as
BEGIN
	--PRODUCCION
	exec [10.0.2.14].finmas.dbo.pCaXObtieneDocDigitalizadoByTipo @codsolicitud, @codoficina, @IdTipoDocumento   
	--PRUEBAS
	--exec [10.0.2.14].finmas_20190107fin.dbo.pCaXObtieneDocDigitalizadoByTipo @codsolicitud, @codoficina, @IdTipoDocumento
	--exec [10.0.2.14].finmas_20190315ini.dbo.pCaXObtieneDocDigitalizadoByTipo @codsolicitud, @codoficina, @IdTipoDocumento
END

GO