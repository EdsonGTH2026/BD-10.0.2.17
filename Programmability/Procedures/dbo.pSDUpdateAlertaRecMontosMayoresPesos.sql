SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDUpdateAlertaRecMontosMayoresPesos](@Id INT, @IdRespuesta INT, @DictamenObservacion VARCHAR(500))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDUpdateAlertaRecMontosMayoresPesos] @Id, @IdRespuesta, @DictamenObservacion
END
GO