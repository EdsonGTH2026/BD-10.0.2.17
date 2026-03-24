SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaNotificacionGuardar]  
@id integer, @descripcion varchar(50), @texto1 varchar(100), @texto2 varchar(100), 
@nombrearchivo varchar(30), @ruta varchar(200), @vigenciaini smalldatetime, @vigenciafin smalldatetime,
@predeterminada smallint,
@activo smallint, @idnotificaciontipo integer, @codusalta varchar(20)
as
begin

	if not exists(select * from tCsXaNotificaciones where IdNotificacion = @id )
		begin
			insert into tCsXaNotificaciones ( Descripcion, Texto1, Texto2, NombreArchivo, Ruta,RutaWeb,VigenciaInicial, VigenciaFinal, Predeterminada, Activo, IdNotificacionTipo, FechaAlta, CodUsAlta, FechaModificacion, CodUsModificacion )
			values (@descripcion, @texto1, @texto2, @nombrearchivo, @ruta, 'http://200.57.180.150/notificacionesapp/', @vigenciaini, @vigenciafin, @predeterminada, @activo, @idnotificaciontipo, getdate(), @codusalta, getdate(), @codusalta )
		end
	else
		begin
			update tCsXaNotificaciones set
			Descripcion = @descripcion, Texto1 =@texto1, Texto2 = @texto2, 
			NombreArchivo = @nombrearchivo, Ruta = @ruta,VigenciaInicial = @vigenciaini, 
			VigenciaFinal = @vigenciafin, Activo = @activo, FechaModificacion = getdate(), 
			IdNotificacionTipo = @idnotificaciontipo,
			CodUsModificacion = @codusalta,
			Predeterminada = @predeterminada
			where IdNotificacion = @id
		end

end
GO