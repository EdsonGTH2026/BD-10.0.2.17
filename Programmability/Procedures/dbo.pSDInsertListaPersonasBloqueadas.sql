SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDInsertListaPersonasBloqueadas](@IdArchivo INT, @IdTipo INT, @Tipo VARCHAR(50), @FechaOficio SMALLDATETIME, 
														 @Nombre VARCHAR(100), @ApellidoPaterno VARCHAR(50), @ApellidoMaterno VARCHAR(50), 
														 @RFC VARCHAR(13), @FechaNacimiento SMALLDATETIME, @Motivo VARCHAR(4), 
														 @NombreArchivo VARCHAR(50))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDInsertListaPersonasBloqueadas] @IdArchivo, @IdTipo, @Tipo, @FechaOficio, @Nombre, @ApellidoPaterno, 
																			@ApellidoMaterno, @RFC, @FechaNacimiento, @Motivo, @NombreArchivo
END
GO