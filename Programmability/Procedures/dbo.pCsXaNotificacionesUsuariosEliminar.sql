SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaNotificacionesUsuariosEliminar] @idnotificacion integer, @codsusuarios varchar(500)
as
BEGIN

	delete from tCsXaNotificacionUsuario
	where 
	IdNotificacion = @idnotificacion
	and CodUsuario in (select value from dbo.fSplit (',',@codsusuarios))

END
GO