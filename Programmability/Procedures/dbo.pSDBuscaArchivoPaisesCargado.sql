SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscaArchivoPaisesCargado](@NombreArchivo VARCHAR(50))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscaArchivoPaisesCargado] @NombreArchivo
END
GO