SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCrecimientoPromotorTodos]
as
	set nocount on

	truncate table tCsACrecimientoPromotor

	create table #o (sec int identity(1,1),codoficina varchar(4))
	insert into #o(codoficina)
	select codoficina from tcloficinas with(nolock) where tipo<>'Cerrada'
	and codoficina not in('98','97','99','230','231')
	and (cast(codoficina as int)<=99 or cast(codoficina as int)>=300)

	declare @codoficina varchar(4)
	declare @n int
	declare @x int
	select @n=count(*) from #o
	set @x=1
	while(@x<=@n)
	begin
		select @codoficina=codoficina from #o where sec=@x
		--print @codoficina
		exec pCsACaCrecimientoPromotor @codoficina
		--print @x
		set @x=@x+1
	end

	drop table #o
GO