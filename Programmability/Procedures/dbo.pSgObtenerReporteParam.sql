SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSgObtenerReporteParam] @ID int AS
set nocount on
SELECT     Nombre, Etiqueta, TipoDato, FuenteDatos, CampoMostrar, CampoValor, Visible, PorDefecto, tipoobjeto,comillas, paramfiltro, paramvalor, RespMinima
FROM         tSgReportesParametros with(nolock)
WHERE     (CodReporte = @ID)
GO