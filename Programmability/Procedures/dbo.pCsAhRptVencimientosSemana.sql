SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAhRptVencimientosSemana] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20150304'

declare @VariosPeriodos varchar(200)
set @VariosPeriodos = dbo.fdufechaaperiodo(@fecha) + ',' + dbo.fdufechaaperiodo(dateadd(month,1,@fecha)) + ',' + dbo.fdufechaaperiodo(dateadd(month,2,@fecha))

select ps.nrosemana, ps.fechaini, ps.fechafin
,count(a.codcuenta) nro, sum(a.saldocuenta+a.intacumulado) saldocuenta, sum(a.intacumulado) intacumulado
,count(case when a.codoficina='98' then a.codcuenta else null end) nroOfCen
,sum(case when a.codoficina='98' then a.saldocuenta + a.intacumulado else 0 end) saldocuentaOfCen
,sum(case when a.codoficina='98' then a.intacumulado else 0 end) intacumuladoOfCen
,count(case when a.codoficina<>'98' then a.codcuenta else null end) nroSinOfCen
,sum(case when a.codoficina<>'98' then a.saldocuenta + a.intacumulado else 0 end) saldocuentaSinOfCen
,sum(case when a.codoficina<>'98' then a.intacumulado else 0 end) intacumuladoSinOfCen
from tcsahorros a with(nolock)
inner join (select * from fduTablaSemanaPeriodosFuturos(@VariosPeriodos)) ps 
on a.fechavencimiento>=ps.fechaini and a.fechavencimiento<=ps.fechafin
where substring(a.codcuenta,5,1)='2' and a.fecha=@fecha
group by ps.nrosemana, ps.fechaini, ps.fechafin


GO