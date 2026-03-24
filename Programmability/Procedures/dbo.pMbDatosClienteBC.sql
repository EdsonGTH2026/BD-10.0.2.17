SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure [pMbDatosClienteBC]
CREATE procedure [dbo].[pMbDatosClienteBC] @codusuario varchar(15)
as
select top 1 u.materno,u.paterno,u.nombres,u.fechanacimiento, d.codpostal, d.direccion +' '+ numexterno direccion 
,m.descubigeo municipio,e.campo3 estado, u.codoficina ,o.nomoficina, z.nombre
from [10.0.2.14].FinMas.dbo.tususuarios u
inner join [10.0.2.14].FinMas.dbo.tususuariodireccion d
on u.codusuario=d.codusuario --and (d.familiarnegocio='F' or d.familiarnegocio='N')
inner join tclubigeo ub with(nolock) on ub.codubigeo=d.codubigeo 
inner join tclubigeo m with(nolock) on m.codarbolconta=substring(ub.codarbolconta,1,19) 
inner join tclubigeo e with(nolock) on e.codarbolconta=substring(ub.codarbolconta,1,13)
inner join tcloficinas o with(nolock) on o.codoficina=case when u.codoficina='98' then '42' else u.codoficina end
inner join tclzona z with(nolock) on z.zona=o.zona
--where u.codusuario='98UMC1809791'
where u.codusuario=@codusuario

GO