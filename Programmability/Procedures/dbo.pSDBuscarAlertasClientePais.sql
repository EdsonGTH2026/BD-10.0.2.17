SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarAlertasClientePais](@FechaInicial DATETIME, @FechaFinal DATETIME, @TipoAlerta INT)
AS
	exec [10.0.2.14].finamigoPLD.dbo.pSDBuscarAlertasClientePais @FechaInicial, @FechaFinal, @TipoAlerta
GO