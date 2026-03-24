SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaPromotoresxSucursal] @codoficina varchar(500)
as
		----exec [10.0.2.14].finmas.dbo.pXaPromotoresxSucursal @codoficina
		--declare @codoficina varchar(500)
		--set @codoficina='301,101,307,107,308,108,320,120,339,139,432,232,434,234,435,235'
		select cl.codusuario codasesor,cl.nombrecompleto nomasesor,cl.codorigen
		from tcsempleados e with(nolock) 
		inner join tcspadronclientes cl with(nolock) on e.codusuario=cl.codusuario
		where e.estado=1 and e.codoficinanom in(
			select codigo from dbo.fduTablaValores(@codoficina)
		)
		union
		select cl.codusuario codasesor,cl.nombrecompleto nomasesor,cl.codorigen
		from tclzona e with(nolock)
		inner join tcspadronclientes cl with(nolock) on e.responsable=cl.codusuario
		where e.activo=1 
		and e.zona in(
				select distinct zona from tcloficinas with(nolock) where codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
		)
GO