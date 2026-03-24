SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasPersonasBloqueadas](@FechaInicial DATETIME, @FechaFinal DATETIME, @Nombre VARCHAR(100),
														    @ApellidoPaterno VARCHAR(50), @ApellidoMaterno VARCHAR(50), @TipoAlerta INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarAlertasPersonasBloqueadas] @FechaInicial, @FechaFinal, @Nombre, @ApellidoPaterno, 
																			  @ApellidoMaterno, @TipoAlerta
END
GO