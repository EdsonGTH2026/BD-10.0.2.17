SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaNotificacionesUsuariosConsulta]  @idsnotificaciones varchar(200)
as
BEGIN
	select 
	ucl.NickUsuario,
	pc.CodUsuario, pc.NombreCompleto, 
--pc.CodOficina, 
--	o.NomOficina,
	nu.IdNotificacion,
	n.Descripcion
	from tSgUsuariosCLine as ucl with(nolock) 
    inner join tCsPadronClientes as pc with(nolock) on pc.codusuario = ucl.codusuario
--	inner join tClOficinas as o with(nolock) on o.codoficina = pc.CodOficina
	inner join tCsXaNotificacionUsuario as nu with(nolock) on nu.CodUsuario = ucl.CodUsuario
	inner join tCsXaNotificaciones as n with(nolock) on n.IdNotificacion = nu.IdNotificacion
	where pc.Activo = 1 
	and nu.IdNotificacion in (select value from dbo.Split1 (@idsnotificaciones)) --(@idsnotificaciones)

END
GO