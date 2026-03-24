SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSDBuscarRutaDocsRiesgoCliente](@NroSolicitud VARCHAR(15), @CodOficina VARCHAR(4))
AS
BEGIN
	EXEC [10.0.2.14].[FinamigoPLD].[dbo].[pSDBuscarRutaDocsRiesgoCliente] @NroSolicitud, @CodOficina
END
GO