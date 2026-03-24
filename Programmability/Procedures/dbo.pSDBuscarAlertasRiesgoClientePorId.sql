SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasRiesgoClientePorId](@IdAlerta INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarAlertasRiesgoClientePorId] @IdAlerta
END
GO