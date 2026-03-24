SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCARptPrograPagadoPromotor] @codoficina varchar(2000)
as

	declare @sucursales table(codigo varchar(4))
	insert into @sucursales
	select codigo 
	from dbo.fduTablaValores(@codoficina)

	select * from tCsACaPrograPagadoPromotor with(nolock)
	where codoficina in(select codigo from @sucursales)
GO