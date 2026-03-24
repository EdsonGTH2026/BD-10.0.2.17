SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA 7. TENDENCIA DE CARTERA FA POR BUCKETS */

Create Procedure [dbo].[pCsCaReporteDiarioT7]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @fech table (fecha smalldatetime)
insert into @fech 
select ultimodia from tclperiodo where ultimodia>=dateadd(month,-12,@fecha) and ultimodia<=@fecha union select @fecha

select fecha fechaPeriodo
,sum(saldocapital) saldoCapitalTotal
,(sum(case when nrodiasatraso>=31 then saldocapital else 0 end)/ sum(saldocapital))*100 'CARTERA31'
,(sum(case when nrodiasatraso>=90  then saldocapital else 0 end)/sum(saldocapital))*100 'CARTERA90'
into #base
from tcscartera i with(nolock)
where fecha in(select fecha from @fech)
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by fecha
 
select @fecha fecha,fechaPeriodo,CARTERA31 saldoCapital
,'%CARTERA 31+ vs CARTERA TOTAL'categoria
from #base
union
select @fecha fecha,fechaPeriodo,CARTERA90 saldoCapital
,'%CARTERA 90+ vs CARTERA TOTAL'
from #base

drop table #base
GO