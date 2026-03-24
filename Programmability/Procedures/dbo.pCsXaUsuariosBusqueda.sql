SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaUsuariosBusqueda]  @nombre varchar(100)
as
begin
	select top 20 pc.CodUsuario, pc.NombreCompleto, pc.UsRFC, pc.FechaNacimiento, pc.CodOficina, 
	o.NomOficina,
	isnull(pc.DireccionDirFamPri,'') as Direccion,
	isnull(pc.CodUbiGeoDirFamPri,'') as CodUbigeo,
	isnull(pc.NumExtFam,  '') as NumExt,
	isnull(NumIntFam,'') as NumInt,
	isnull(dir.Colonia,'') as Colonia, isnull(dir.Municipio,'') as Municipio , isnull(dir.estado,'') as Estado,
    pc.FechaIngreso,
	isnull(ucl.NroCelular,'') as Celular, 
	isnull(ucl.email,'') as email,
	isnull(ucl.NickUsuario,'') as NickUsuario,
	isnull(claveacceso,'') as claveacceso  
	from tCsPadronClientes as pc with(nolock)
	inner join tClOficinas as o with(nolock) on o.codoficina = pc.CodOficina
	left join vCsUbigeoColonia as dir on dir.CodUbiGeo = pc.CodUbiGeoDirFamPri
	left join tSgUsuariosCLine as ucl with(nolock) on ucl.codusuario = pc.codusuario
	where pc.Activo = 1 
    and pc.NombreCompleto like '%' + @nombre + '%'

end

GO