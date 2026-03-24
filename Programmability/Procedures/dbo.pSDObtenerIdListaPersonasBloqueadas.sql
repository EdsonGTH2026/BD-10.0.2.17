SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDObtenerIdListaPersonasBloqueadas](@NombreArchivo VARCHAR(50))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDObtenerIdListaPersonasBloqueadas] @NombreArchivo
END
GO