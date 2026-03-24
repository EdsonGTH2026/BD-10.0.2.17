SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaUsuariosClaveAcceso] @claveacceso varchar(50)
as
begin
	exec [10.0.2.17].finamigoconsolidado.dbo.pCsXaUsuariosClaveAcceso  @claveacceso
end
GO