SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsPrComentario]
@Fecha 	SmallDateTime,
@Reporte	Varchar(10)
As

SELECT DISTINCT Comentario, DetComentario
FROM         tCsPrRegulatorios
WHERE     (Fecha = @Fecha) AND (Comentario IS NOT NULL) AND (Reporte = @Reporte)
GO