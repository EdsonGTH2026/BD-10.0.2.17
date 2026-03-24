SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA 11. RESULTADOS 2021  */

Create Procedure [dbo].[pCsCaReporteDiarioT11] 
as 
set nocount on

declare @fech table(fecha smalldatetime)
insert into @fech
select ultimodia from tclperiodo where ultimodia>=dateadd(month,-11,'20211231') and ultimodia<='20211231'

select fecha,periodo,InteDevengado, gastoxinteres,eprc,co_cobradaPagada,inteDevengado+co_cobradaPagada-gastoxInteres-EPRC Total
into #base
FROM fnmgconsolidado.dbo.tcaReporteDiario
where fecha in (select fecha from @fech )

Select fecha,periodo,'1.INGRESO POR INTERESES' CATEGORIA,intedevengado Valor
from #base
UNION
Select fecha,periodo,'2.GASTO POR INTERESES' CATEGORIA,gastoxinteres Valor
from #base
UNION
Select fecha,periodo,'3.GASTO EPRC' CATEGORIA,eprc Valor
from #base
UNION
Select fecha,periodo,'4.COMISIÓN COBRADA' CATEGORIA,co_cobradapagada Valor
from #base
UNION
Select fecha,periodo,'5.TOTAL' CATEGORIA,total Valor
from #base
drop table #base
GO