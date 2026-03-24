SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaPagosPrograPromSemanaDatos_vs2] @fecha smalldatetime, @codoficina varchar(2000)
as

	--declare @codoficina varchar(2000)
	--set @codoficina='%'--'37,4,3,6'

	declare @oficinas table(codoficina varchar(4))
	insert into @oficinas
	select codigo
	from dbo.fdutablavalores(@codoficina)

	select * from tCsACaPagosPrograPromSemana_vs2 with(nolock)
	where (@codoficina<>'%' and codoficina in(select codoficina from @oficinas)) or (@codoficina='%')
GO