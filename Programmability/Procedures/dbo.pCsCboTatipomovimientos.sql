SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCboTatipomovimientos]
AS
BEGIN
	SET NOCOUNT ON;

  SELECT CodTipoMov,Descripcion
  FROM tTaTipoMovimientos

END
GO