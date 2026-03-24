SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXaConsultarUsuarioCLine]  @usuario varchar(30)
as
begin
	select top 1 pc.CodUsuario, uc.NickUsuario, pc.NombreCompleto, pc.UsRFC, pc.FechaNacimiento, pc.CodOficina, 
	o.NomOficina,
	isnull(pc.DireccionDirFamPri,'') as Direccion,
	isnull(pc.CodUbiGeoDirFamPri,'') as CodUbigeo,
	isnull(pc.NumExtFam,  '') as NumExt,
	isnull(NumIntFam,'') as NumInt,
	isnull(dir.Colonia,'') as Colonia, isnull(dir.Municipio,'') as Municipio , isnull(dir.estado,'') as Estado,
	isnull(uc.NroCelular,'') as NroCelular, 
	isnull(uc.email,'') as email, 
    pc.FechaIngreso 
	from 
	tSgUsuariosCLine as uc with(nolock) 
	inner join tCsPadronClientes as pc with(nolock) on pc.codusuario = uc.codusuario  
	inner join tClOficinas as o with(nolock) on o.codoficina = pc.CodOficina
	left join vCsUbigeoColonia as dir on dir.CodUbiGeo = pc.CodUbiGeoDirFamPri
	where pc.Activo = 1 
    and uc.NickUsuario = @usuario

end   
GO