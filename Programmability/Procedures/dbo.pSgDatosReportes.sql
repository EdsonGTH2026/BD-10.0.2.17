SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgDatosReportes] @Codigo int  AS
SELECT     CodModulo, Fuentedatos, Nombre, Titulo, Descripcion,  
                      RutaUbicacion, RutaDesarrollo, FechaUltModificacion, Activo
FROM         tSgReportes
WHERE     (CodReporte = @Codigo)
GO