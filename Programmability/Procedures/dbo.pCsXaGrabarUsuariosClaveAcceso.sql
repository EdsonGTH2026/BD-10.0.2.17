SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaGrabarUsuariosClaveAcceso]  @codusuario varchar(20), @NickUsuario varchar(10), @claveacceso varchar(30)
as
begin

	update tSgUsuariosCLine set
	claveacceso = @claveacceso
	where codusuario = @codusuario
	and @NickUsuario = @NickUsuario
end
GO