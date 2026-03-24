SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaUsuarioCLineBusqueda]  @nombre varchar(100), @usuario varchar(15), @codusuario varchar(20)
as
begin
	select top 20 
	ucl.NickUsuario,
	pc.CodUsuario, pc.NombreCompleto, 
	--pc.UsRFC, pc.FechaNacimiento, pc.CodOficina, 
	o.NomOficina,
	--0 as NroNotificaciones
	(select count(IdNotificacion) 
	 from tCsXaNotificacionUsuario with(nolock)
	 where Activo = 1
	 and VigenciaInicial <= getdate() and VigenciaFinal >= getdate()
	 and CodUsuario = ucl.codusuario) as NroNotificaciones
	from tSgUsuariosCLine as ucl with(nolock) 
    inner join tCsPadronClientes as pc with(nolock) on pc.codusuario = ucl.codusuario
	inner join tClOficinas as o with(nolock) on o.codoficina = pc.CodOficina
	--left join vCsUbigeoColonia as dir on dir.CodUbiGeo = pc.CodUbiGeoDirFamPri
	where pc.Activo = 1 
    and pc.NombreCompleto like '%' + @nombre + '%'
	and ucl.NickUsuario like '%' + @usuario + '%'
	and ucl.CodUsuario like '%' + @codusuario + '%'
end
GO