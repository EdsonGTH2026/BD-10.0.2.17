SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscaArchivoPaisesCargadoDetalle](@IdArchivo INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscaArchivoPaisesCargadoDetalle] @IdArchivo
END
GO