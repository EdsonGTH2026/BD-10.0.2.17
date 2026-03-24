SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDUpdateAlertaClientePais](@Id INT, @IdRespuesta INT, @DictamenObservacion VARCHAR(500))
AS
BEGIN
	exec [10.0.2.14].finamigoPLD.dbo.pSDUpdateAlertaClientePais @Id , @IdRespuesta , @DictamenObservacion
END
GO