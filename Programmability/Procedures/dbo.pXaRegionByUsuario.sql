SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaRegionByUsuario] (@usuario varchar(20))
as
begin
	set nocount on
	select --@zona=zona 
	Zona, Nombre, Responsable
	from tclzona
	where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@usuario)
end
GO