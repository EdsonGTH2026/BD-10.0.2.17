SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaUsuarioCLinePassword] @usuario varchar(20), @claveacceso varchar(50)
as
begin
	update tSgUsuariosCLine set			
	claveacceso = @claveacceso
	where
	--codusuario = @codusuario
	NickUsuario = @usuario
end
GO