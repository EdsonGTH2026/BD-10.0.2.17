SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCboTransacTesoreria]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Select	TipoTransacNivel3,Descripcion  
	From	tCsClTipoTransacNivel3
	Where	CodSistema='TC'

END
GO