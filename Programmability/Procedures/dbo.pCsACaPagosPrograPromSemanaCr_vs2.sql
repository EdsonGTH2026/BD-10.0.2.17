SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaPagosPrograPromSemanaCr_vs2] @codoficina varchar(1000)
as
	declare @oficinas table(codoficina varchar(4))
	insert into @oficinas
	select codigo
	from dbo.fdutablavalores(@codoficina)

	--Declare @fecha smalldatetime
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

	select * from tCsACaPagosPrograPromSemana_vs2 with(nolock)
	where codoficina in(select codoficina from @oficinas)
	--and fecha='20200705'--@fecha
	
GO