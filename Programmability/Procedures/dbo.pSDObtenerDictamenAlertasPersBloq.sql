SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDObtenerDictamenAlertasPersBloq](@Id INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDObtenerDictamenAlertasPersBloq] @Id
END
GO