SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDInsertListaArchivosPaisesCargados](@IdArchivo INT, @CodPais VARCHAR(4), @Pais VARCHAR(80), @Nacionalidad VARCHAR(80), 
															  @Continente VARCHAR(20), @Riesgo VARCHAR(10), @NombreArchivo VARCHAR(50))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDInsertListaArchivosPaisesCargados] @IdArchivo, @CodPais, @Pais, @Nacionalidad, @Continente, 
																				@Riesgo, @NombreArchivo
END
GO