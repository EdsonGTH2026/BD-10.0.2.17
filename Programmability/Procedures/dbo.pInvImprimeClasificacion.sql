SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pInvImprimeClasificacion
CREATE PROCEDURE [dbo].[pInvImprimeClasificacion]
AS

SET NOCOUNT ON 

SELECT c.idgrupo, g.descripcion, c.idtipo, t.descripcion, c.codclase, c.descripcion, c.idgrupo, c.idtipo, c.codclase
  FROM tClClasificacion c
 INNER JOIN tClTipo  t ON c.idgrupo = t.idgrupo AND c.idtipo = t.idtipo 
 INNER JOIN tclGrupo g ON c.idgrupo = g.idgrupo
 ORDER BY c.idgrupo, c.idtipo, c.codclase
 
GO