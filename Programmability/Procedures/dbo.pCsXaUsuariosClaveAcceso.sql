SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaUsuariosClaveAcceso] @claveacceso varchar(50)
as
begin

	--SELECT master.dbo.fn_md5_2(master.dbo.fn_md5_2(@claveacceso)) as contrasena
	SELECT dbo.fduMD5(dbo.fduMD5(@claveacceso)) as contrasena
end
GO