SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaPagosPrograPromSemanaCr] @codoficina varchar(1000)
as
	declare @oficinas table(codoficina varchar(4))
	insert into @oficinas
	select codigo
	from dbo.fdutablavalores(@codoficina)

	Declare @fecha smalldatetime
	select @fecha=fechaconsolidacion from vcsfechaconsolidacion

	select * from tCsACaPagosPrograPromSemana with(nolock)
	where codoficina in(select codoficina from @oficinas)
	and fecha=@fecha
GO