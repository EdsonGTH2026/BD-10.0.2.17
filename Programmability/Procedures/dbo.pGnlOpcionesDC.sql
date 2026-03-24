SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pGnlOpcionesDC]
As
	SELECT DISTINCT 
	                      REPLACE(dbo.fduCamino(1, tSgOptions.Opcion), '/', '') AS Codigo, tSgModulos.Nombre AS Modulo, tSgOptions.Nombre, dbo.fduCamino(2, tSgOptions.Opcion) 
	                      AS RutaOpcion, tSgOptions.Descripcion + '|' + ISNULL(tSgReportes.Titulo, '') + '; ' + CAST(ISNULL(tSgReportes.Descripcion, '') AS Varchar(8000)) AS Descripcion, 
	                      tSgReportes.Fuentedatos, tSgReportes.RutaUbicacion, tSgReportes.FechaCreacion, dbo.fduCamino(3, tSgOptions.Opcion) AS Parametros, 
	                      ISNULL(tSgUsuarios.NombreCompleto, tSgReportes.UsuarioRegistro) AS Desarrollador, dbo.fduCamino(4, tSgOptions.Opcion) AS PerfilesAccesos
	FROM         tSgModulos INNER JOIN
	                      tSgReportes ON tSgModulos.CodModulo = tSgReportes.CodModulo INNER JOIN
	                      tSgUsuarios ON tSgReportes.UsuarioRegistro = tSgUsuarios.Usuario RIGHT OUTER JOIN
	                      tSgOptions ON tSgReportes.CodReporte = tSgOptions.Objeto
	WHERE     (tSgOptions.CodSistema = 'DC') AND (tSgOptions.EsTerminal = 1) AND (tSgOptions.Activo = 1)
	ORDER BY REPLACE(dbo.fduCamino(1, tSgOptions.Opcion), '/', '')
GO