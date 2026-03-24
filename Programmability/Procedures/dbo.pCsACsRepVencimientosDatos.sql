SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACsRepVencimientosDatos] @fecha smalldatetime, @codoficina varchar(500)
as
	declare @oficinas table(codoficina varchar(4))

	if(@codoficina<>'%')
	begin
		insert into @oficinas
		select codigo
		from dbo.fdutablavalores(@codoficina)
	end
	else
	begin
		insert into @oficinas
		select codoficina
		from tcloficinas with(nolock)
		where tipo<>'Cerrada'
		and (cast(codoficina as int)<100 or cast(codoficina as int)>300)
		and codoficina not in('97','99','98')
	end

	select *
	from tCsARepVencimientos with(nolock)
	where codoficina in(
		select codoficina from @oficinas
	)
GO