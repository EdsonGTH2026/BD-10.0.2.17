SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgOpcionesGrupo] @Grupo varchar(15) AS
SELECT     tSgAcciones.Opcion, tSgOptions.Nombre, tSgAcciones.Acceder, tSgAcciones.Anadir, tSgAcciones.Editar, tSgAcciones.Grabar, tSgAcciones.Cancelar, 
                      tSgAcciones.Eliminar, tSgAcciones.Imprimir, tSgAcciones.Cerrar
FROM         tSgAcciones INNER JOIN
                      tSgOptions ON tSgAcciones.CodSistema = tSgOptions.CodSistema AND tSgAcciones.Opcion = tSgOptions.Opcion
WHERE     (tSgAcciones.CodSistema = 'DC') AND (tSgAcciones.CodGrupo = @Grupo) AND (tSgOptions.Activo = 1)
UNION ALL
SELECT     Opcion, Nombre, cast(0 as bit) AS Acceder,cast(0 as bit) AS Anadir, cast(0 as bit) AS Editar, cast(0 as bit) AS Grabar, cast(0 as bit) AS Cancelar,cast(0 as bit) AS Eliminar, cast(0 as bit) AS Imprimir, cast(0 as bit) AS Cerrar
FROM         tSgOptions
WHERE    codsistema = 'DC' and  (Activo = 1) AND (Opcion NOT IN
                          (SELECT     Opcion
                            FROM          tSgAcciones
                            WHERE      (CodSistema = 'DC') AND (CodGrupo = @Grupo))) AND (EsTerminal = 1)
GO