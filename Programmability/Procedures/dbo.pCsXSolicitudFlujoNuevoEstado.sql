SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXSolicitudFlujoNuevoEstado](@idproceso varchar(10), @usuario varchar(15), @newestado varchar(3), @observaciones varchar(1000))
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaXSolicitudFlujoNuevoEstado @idproceso, @usuario, @newestado, @observaciones  --PRODUCCION
	--exec [10.0.2.14].alta14.dbo.pCaXSolicitudFlujoNuevoEstado @idproceso, @usuario, @newestado, @observaciones  --PRUEBAS
END
GO