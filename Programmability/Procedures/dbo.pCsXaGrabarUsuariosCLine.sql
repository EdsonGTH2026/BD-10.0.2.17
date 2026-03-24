SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaGrabarUsuariosCLine] @codusuario varchar(20), @NickUsuario varchar(10), @email varchar(50), @NroCelular varchar(10), @CodOficina varchar(3), @claveacceso varchar(30)
as
begin
	if not exists(select * from tSgUsuariosCLine where codusuario = @codusuario)
		begin
			insert into tSgUsuariosCLine(NickUsuario, tiponick, codusuario, email, NroCelular, FechaAlta, FechaVigencia, CambiaContrasena, RenuevaVigencia, Activo, CodOficina, claveacceso, claveverificacion, nroenvio, RContrato )
			values (@NickUsuario, 1, @codusuario, @email, @NroCelular, getdate(), dateadd(year,1,getdate()) , 1, 1, 1, @CodOficina, @claveacceso, null, 0, null )
		end
	else
		begin
			update tSgUsuariosCLine set
			NickUsuario = @NickUsuario,
			email = @email,
			NroCelular= @NroCelular,
			claveacceso = @claveacceso
			where
			codusuario = @codusuario
		end
end
         
GO