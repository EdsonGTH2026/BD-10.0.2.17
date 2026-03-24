SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDObtenerDictamenAlertasRiesgoCliente](@Id INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDObtenerDictamenAlertasRiesgoCliente] @Id
END
GO