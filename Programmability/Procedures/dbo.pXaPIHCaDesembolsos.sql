SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaPIHCaDesembolsos
CREATE procedure [dbo].[pXaPIHCaDesembolsos]
as

declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion+1 from vcsfechaconsolidacion
--set @fecfin='20181031'

declare @dia varchar(2)
set @dia=replicate('0',2-len(cast(day(@fecfin) as varchar(2)))) + cast(day(@fecfin) as varchar(2))

declare @fecini smalldatetime
--set @fecini=cast(year(@fecfin) as char(4))+'0101'
set @fecini=dbo.fdufechaaperiodo(dateadd(month,-11,@fecfin))+'01'

declare @f table(primerdia smalldatetime,ultimodia smalldatetime)
insert into @f
select primerdia
,case when day(ultimodia)<cast(@dia as int) then ultimodia else cast(dbo.fdufechaaperiodo(ultimodia)+@dia as smalldatetime) end
from tclperiodo where primerdia>=@fecini
--select * from @f
--select dbo.fdufechaaperiodo(desembolso) periodo
--,round(sum(monto)/1000,0) monto
--from tcspadroncarteradet with(nolock)
--where desembolso>=@fecini--'20180101'
--and desembolso<=@fecfin--'20181022'
--and codoficina<>'97'
--group by dbo.fdufechaaperiodo(desembolso)
--order by dbo.fdufechaaperiodo(desembolso)

declare @t table(periodo varchar(10), monto money)
insert into @t
select dbo.fdufechaaperiodo(fechadesembolso) x,round(sum(montodesembolso)/1000,0) monto
from [10.0.2.14].finmas.dbo.tcaprestamos
where fechadesembolso=@fecfin--+1 
and estado='VIGENTE'
and codoficina not in('97','98','999')
group by dbo.fdufechaaperiodo(fechadesembolso)

--select * from @t
--select a.periodo,a.monto+isnull(x.monto,0) monto
--from (
--	select dbo.fdufechaaperiodo(p.desembolso) periodo
--	,round(sum(p.monto)/1000,0) monto
--	from tcspadroncarteradet p with(nolock)
--	inner join @f f on f.primerdia<=desembolso and f.ultimodia>=desembolso
--	where p.codoficina<>'97'
--	group by dbo.fdufechaaperiodo(p.desembolso)	
--) a
--left outer join @t x on x.periodo=a.periodo
--order by a.periodo

select periodo,sum(monto) monto
from (
	select * from @t
	union
	select dbo.fdufechaaperiodo(p.desembolso) periodo
	,round(sum(p.monto)/1000,0) monto
	from tcspadroncarteradet p with(nolock)
	inner join @f f on f.primerdia<=desembolso and f.ultimodia>=desembolso
	where p.codoficina not in('97','98','999')
	group by dbo.fdufechaaperiodo(p.desembolso)	
) x
group by periodo
GO