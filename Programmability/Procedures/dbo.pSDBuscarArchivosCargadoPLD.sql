SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarArchivosCargadoPLD](@NombreArchivo VARCHAR(50), @Nombre VARCHAR(100), 
										 			 @ApellidoPaterno VARCHAR(50), @ApellidoMaterno VARCHAR(50))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarArchivosCargadoPLD] @NombreArchivo, @Nombre, @ApellidoPaterno, @ApellidoMaterno
END
GO