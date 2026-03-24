SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDDetalleArchivoCargadoPLD](@IdArchivo INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDDetalleArchivoCargadoPLD] @IdArchivo
END
GO