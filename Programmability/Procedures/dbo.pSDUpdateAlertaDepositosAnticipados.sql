SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDUpdateAlertaDepositosAnticipados](@Id INT, @IdRespuesta INT, @DictamenObservacion VARCHAR(500))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDUpdateAlertaDepositosAnticipados] @Id, @IdRespuesta, @DictamenObservacion
END
GO