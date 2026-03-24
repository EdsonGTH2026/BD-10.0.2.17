SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* TABLA 9. COMPARACION DE CARTERA TOTAL  */

Create Procedure [dbo].[pCsCaReporteDiarioT9] @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @m int
set @m= cast(month(@fecha) as int)+23 --mostrar registro de 2 años atras y los meses del año actual

declare @fech table(fecha smalldatetime)
insert into @fech
select ultimodia from tclperiodo where ultimodia>=dateadd(month,-@m,@fecha) and ultimodia<=@fecha
union select @fecha

select @fecha fechaCorte,fecha fecha,substring(dbo.fdufechaaperiodo(fecha),5,2) fechaperiodo
,substring(dbo.fdufechaaperiodo(fecha),1,4)periodoAnual,
sum(saldocapital) saldoCapital
from tcscartera  with(nolock)
where fecha in(select fecha from @fech)
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by fecha order by fecha
GO