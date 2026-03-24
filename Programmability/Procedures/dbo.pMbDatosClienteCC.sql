SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pMbDatosClienteCC
create procedure [dbo].[pMbDatosClienteCC] @codusuario varchar(15)
as
select top 1 u.materno,u.paterno,u.nombres,u.fechanacimiento, d.codpostal, d.direccion +' '+ numexterno direccion 
,m.descubigeo municipio,e.campo3 estado 
from FinMas_20130930.dbo.tususuarios u with(nolock) inner join FinMas_20130930.dbo.tususuariodireccion d with(nolock) 
on u.codusuario=d.codusuario and familiarnegocio='F' 
inner join tclubigeo ub with(nolock) on ub.codubigeo=d.codubigeo 
inner join tclubigeo m with(nolock) on m.codarbolconta=substring(ub.codarbolconta,1,19) 
inner join tclubigeo e with(nolock) on e.codarbolconta=substring(ub.codarbolconta,1,13) 
--where u.codusuario='98UMC1809791'
where u.codusuario=@codusuario
GO