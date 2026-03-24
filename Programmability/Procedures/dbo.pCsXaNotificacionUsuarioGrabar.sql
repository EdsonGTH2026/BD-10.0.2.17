SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaNotificacionUsuarioGrabar]  @codusuario varchar(20), @idnotificacion integer, @vigenciaini smalldatetime, @vigenciafin smalldatetime, @activo integer
as
begin

	if not exists(select * from tCsXaNotificacionUsuario where CodUsuario = @codusuario and IdNotificacion = @idnotificacion)
		begin
			insert into tCsXaNotificacionUsuario(CodUsuario, IdNotificacion, VigenciaInicial, VigenciaFinal, Activo, FechaAlta, CodUsAlta, FechaModificacion, CodUsModificacion )
			values (@codusuario, @idnotificacion, @vigenciaini, @vigenciafin, @activo, getdate(), '', getdate(), '' )
		end
	else
		begin
			update tCsXaNotificacionUsuario set
			VigenciaInicial = @vigenciaini, 
			VigenciaFinal = @vigenciafin, 
			Activo = @activo,
			FechaModificacion = getdate(), 
			CodUsModificacion = ''
			where 
			CodUsuario = @codusuario and IdNotificacion = @idnotificacion
		end

end

GO