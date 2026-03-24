SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsARenovaAnticipaPreCalDatos]  @fecha smalldatetime, @codoficina varchar(500)
as
	--declare @codoficina varchar(500)
	--set @codoficina='4,37,3'
	----set @codoficina='%'

	declare @oficinas table(codoficina varchar(4))
	insert into @oficinas
	select codigo
	from dbo.fdutablavalores(@codoficina)

	select * from tCsARenovaAnticipaPreCal with(nolock)
	where (codoficina in(select codoficina from @oficinas)
	or @codoficina='%'
	)
GO