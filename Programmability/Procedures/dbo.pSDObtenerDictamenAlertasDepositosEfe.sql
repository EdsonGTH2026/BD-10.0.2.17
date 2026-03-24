SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDObtenerDictamenAlertasDepositosEfe](@Id INT)
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDObtenerDictamenAlertasDepositosEfe] @Id
END
GO