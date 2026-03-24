SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXSolicitudDocsDigitalizados](@idproceso varchar(10)) as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaXSolicitudDocsDigitalizados @idproceso --PRODUCCION
	--exec [10.0.2.14].alta14.dbo.pCaXSolicitudDocsDigitalizados @idproceso  --PRUEBAS
END
GO