SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXSolicitudFlujoNuevoEstado2](@idproceso varchar(10), @usuario varchar(15), @newestado varchar(2), @observaciones varchar(1000), @fondeosolicitado varchar(20) )
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaXSolicitudFlujoNuevoEstado2 @idproceso, @usuario, @newestado, @observaciones, @fondeosolicitado  --PRODUCCION
	--exec [10.0.2.14].alta14.dbo.pCaXSolicitudFlujoNuevoEstado @idproceso, @usuario, @newestado, @observaciones, @fondeosolicitado  --PRUEBAS
END
GO