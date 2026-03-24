SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACsPagosProgDatos] @fecha smalldatetime, @codoficina varchar(500)
as
--declare @codoficina varchar(200)
--set @codoficina='2,3,4,5,6,7,8'

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
from tCsACAPagosProg
where codoficina in(
	select codoficina from @oficinas
)
GO