SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDObtenerDictamenAlertasClientePais](@Id INT)
AS
	exec [10.0.2.14].finamigoPLD.dbo.pSDObtenerDictamenAlertasClientePais @Id
GO