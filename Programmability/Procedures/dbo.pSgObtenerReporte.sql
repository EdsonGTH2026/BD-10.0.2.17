SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSgObtenerReporte] @Id integer  AS
set nocount on
SELECT     tSgReportes.Nombre, tSgReportes.Titulo, tSgReportes.Descripcion, tSgReportes.RutaUbicacion, tSgModulos.Nombre AS Modulo,
tSgReportes.PersGridAncho,tSgReportes.PersGridAlto,tSgReportes.PersColAncho,tSgReportes.PersColAling,tSgReportes.PersColOrden,
 tSgReportes.fuenteDatos, tSgReportes.PersHeader, tSgReportes.PersHeadFilter, tSgReportes.PersAutoFiltro ,tSgReportes.PersColTipo, tSgReportes.usuarioregistro
FROM         tSgReportes with(nolock) LEFT OUTER JOIN
                      tSgModulos with(nolock) ON tSgReportes.CodModulo = tSgModulos.CodModulo
WHERE     (tSgReportes.CodReporte = @Id)
GO