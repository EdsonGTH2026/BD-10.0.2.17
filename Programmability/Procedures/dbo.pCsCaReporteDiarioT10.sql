SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* TABLA 10. RESULTADOS 2022  */

Create Procedure [dbo].[pCsCaReporteDiarioT10] @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @m int
set @m= cast(month(@fecha) as int)-1 --mostrar registro de 2 años atras y los meses del año actual

declare @fech table(fecha smalldatetime)
insert into @fech
select ultimodia from tclperiodo where ultimodia>=dateadd(month,-@m,@fecha) and ultimodia<=@fecha
union select @fecha

select fecha,periodo,InteDevengado, gastoxinteres,eprc,co_cobradaPagada
,inteDevengado+co_cobradaPagada-gastoxInteres-EPRC Total
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