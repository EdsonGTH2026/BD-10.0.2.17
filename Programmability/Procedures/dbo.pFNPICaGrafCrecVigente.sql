SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pFNPICaGrafCrecVigente]
as
declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
--set @fecfin='20210701'

declare @dia varchar(2)
set @dia=replicate('0',2-len(cast(day(@fecfin) as varchar(2)))) + cast(day(@fecfin) as varchar(2))
--select @dia '@dia'
declare @fecini smalldatetime

set @fecini=dbo.fdufechaaperiodo(dateadd(month,-7,@fecfin))+'01'

declare @f table(sec int identity(1,1),primerdia smalldatetime,ultimodia smalldatetime)
insert into @f (primerdia,ultimodia)
select primerdia-1
,case when day(ultimodia)<cast(@dia as int) then ultimodia else cast(dbo.fdufechaaperiodo(ultimodia)+@dia as smalldatetime) end
from tclperiodo with(nolock) where primerdia>=@fecini
order by primerdia
--declare @t table(fecha smalldatetime, monto money)
--insert into @t
--select fechadesembolso x,sum(montodesembolso) monto
--from [10.0.2.14].finmas.dbo.tcaprestamos
--where fechadesembolso=@fecfin--+1 
--and estado='VIGENTE'
--group by fechadesembolso
--select * from @f
--SELECT dbo.fdufechaaperiodo(fecha) fecha,round(sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo),0) monto
--FROM [FNMGConsolidado].[dbo].[tCACubetasxSuc] with(nolock)
----where day(fecha)=31
--where fecha in(select ultimodia from @f)
--group by dbo.fdufechaaperiodo(fecha)

--select dbo.fdufechaaperiodo(a.fecha) fecha,a.monto-b.monto monto
--from (
--	SELECT c.fecha,f.sec,round(sum(c.D0saldo+c.D1a7saldo+c.D8a15saldo+c.D16a30saldo)/1000,0) monto
--	FROM [FNMGConsolidado].[dbo].[tCACubetasxSuc] c with(nolock)
--	inner join @f f on f.ultimodia=c.fecha
--	where c.fecha in(select ultimodia from @f)
--	group by c.fecha,f.sec
--) a
--inner join(
--	SELECT c.fecha,f.sec,round(sum(c.D0saldo+c.D1a7saldo+c.D8a15saldo+c.D16a30saldo)/1000,0) monto
--	FROM [FNMGConsolidado].[dbo].[tCACubetasxSuc] c with(nolock)
--	inner join @f f on f.primerdia=c.fecha
--	where c.fecha in(select primerdia from @f)
--	group by c.fecha,f.sec
--) b on b.sec=a.sec-1

--select a.sec,a.fecha fecha,a.monto,a.monto-b.monto monto,b.sec,b.fecha,b.monto
select dbo.fdufechaaperiodo(a.fecha) fecha,a.monto-b.monto monto
from (
	SELECT c.fecha,f.sec,round(sum(c.D0saldo+c.D1a7saldo+c.D8a15saldo+c.D16a30saldo)/1000,0) monto
	FROM [FNMGConsolidado].[dbo].[tCACubetasxSuc] c with(nolock)
	inner join @f f on f.ultimodia=c.fecha
	where c.fecha in(select ultimodia from @f)
	and c.codoficina not in('98','501','999')
	group by c.fecha,f.sec
) a
inner join(
	SELECT c.fecha,f.sec,round(sum(c.D0saldo+c.D1a7saldo+c.D8a15saldo+c.D16a30saldo)/1000,0) monto
	FROM [FNMGConsolidado].[dbo].[tCACubetasxSuc] c with(nolock)
	inner join @f f on f.primerdia=c.fecha
	where c.fecha in(select primerdia from @f)
	and c.codoficina not in('98','501','999')
	group by c.fecha,f.sec
) b on b.sec=a.sec
GO