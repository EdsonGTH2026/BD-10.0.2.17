SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscaArchivoPaisesCargadoConFiltros](@NombreArchivo VARCHAR(50), @Pais VARCHAR(80), 
										 					    @Riesgo VARCHAR(10))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscaArchivoPaisesCargadoConFiltros] @NombreArchivo, @Pais, @Riesgo
END
GO