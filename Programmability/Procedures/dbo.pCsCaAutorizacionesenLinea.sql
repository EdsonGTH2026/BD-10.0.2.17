SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE  [dbo].[pCsCaAutorizacionesenLinea]
@Fecha SmallDateTime
 AS
SELECT     tSgAutoEjecutadas.FechaHora, tClOficinas.CodOficina, tClOficinas.DescOficina, tSgAutoEjecutadas.CodAutoriza, tSgAutorizaciones.DescAutoriza, 
                      tSgAutoEjecutadas.Terminal, tSgAutoEjecutadas.CodUsuario, tSgUsuarios.NombreCompleto, tSgAutoEjecutadas.Campo1, tSgAutoEjecutadas.Campo2, 
                      tSgAutoEjecutadas.Motivo, tSgAutoEjecutadas.Exito, tSgAutoEjecutadas.IdAutoEjecutada
FROM         tSgUsuarios INNER JOIN
                      tSgAutoEjecutadas ON tSgUsuarios.CodUsuario = tSgAutoEjecutadas.CodUsuario INNER JOIN
                      tClOficinas ON tSgAutoEjecutadas.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tSgAutorizaciones ON tSgAutoEjecutadas.CodAutoriza = tSgAutorizaciones.CodAutoriza
WHERE     (tSgAutoEjecutadas.FechaHora > = @Fecha)
GO