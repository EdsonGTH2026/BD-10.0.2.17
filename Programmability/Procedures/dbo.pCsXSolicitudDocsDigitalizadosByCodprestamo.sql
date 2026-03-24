SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXSolicitudDocsDigitalizadosByCodprestamo](@codprestamo varchar(20)) as    
BEGIN    
 exec [10.0.2.14].finmas.dbo.pCaXSolicitudDocsDigitalizadosByCodprestamos @codprestamo --PRODUCCION    
 --exec [10.0.2.14].alta14.dbo.pCaXSolicitudDocsDigitalizados @idproceso  --PRUEBAS    
END 
GO