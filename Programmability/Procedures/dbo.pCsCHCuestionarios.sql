SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext pSgOpcionesGrupo
--EXEC pSgOpcionesGrupo 'ADM01'

--SELECT top 20 Codigo, Descripcion FROM tCsCHCuestionarios  WHERE Codigo like '%3%'
--EXEC pCsCHCuestionarios 3
--DROP PROC pCsCHCuestionarios
--SP_HELPTEXT pCsCHCuestionarios
CREATE PROCEDURE [dbo].[pCsCHCuestionarios]
               ( @CodCue INTEGER ) 
AS  
SELECT p.Codigo,  p.CodGrupo, p.CodPregunta, p.Descripcion, --coalesce(p.NroAlternativas,0) NroAlternativas
       case when p.NroAlternativas = 1 then 1 else 0 end NroAlternativas
  FROM tCsCHCuesPreguntas p
 WHERE p.Codigo = @CodCue
 ORDER BY p.Codigo, p.CodGrupo, p.CodPregunta
   
GO