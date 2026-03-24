SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDEliminarArchivoCargadoPLD](@IdArchivo INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDEliminarArchivoCargadoPLD] @IdArchivo
END
GO