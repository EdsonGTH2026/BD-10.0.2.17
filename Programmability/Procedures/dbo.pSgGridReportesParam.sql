SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgGridReportesParam] @Codigo int AS
SELECT     CodParametro, Nombre, Etiqueta
FROM         tSgReportesParametros
WHERE     (CodReporte = @Codigo)
GO