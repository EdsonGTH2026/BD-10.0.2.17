SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAPagosPrograxPromotorDatos] @fecha smalldatetime, @codoficina varchar(1000)
as
	declare @oficinas table(codoficina varchar(4))
	insert into @oficinas
	select codigo
	from dbo.fdutablavalores(@codoficina)

	select * from tCsACaPagosPrograxPromotor with(nolock)
	where codoficina in(select codoficina from @oficinas)
GO