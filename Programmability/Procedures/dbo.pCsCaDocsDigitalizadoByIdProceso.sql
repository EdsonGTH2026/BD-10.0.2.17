SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaDocsDigitalizadoByIdProceso] (@IdProceso integer)
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaDocsDigitalizadoByIdProceso @IdProceso --produccion
	--exec [10.0.2.14].finmas_20190522ini.dbo.pCaDocsDigitalizadoByIdProceso 20000  --pruebas
END
GO