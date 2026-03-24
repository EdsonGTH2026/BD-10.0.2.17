SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaIncOrgCalcInt] @fecfin smalldatetime, @fecini smalldatetime
as
--declare @fecfin smalldatetime
--set @fecfin='20201007'
--declare @fecini smalldatetime
--set @fecini='20201001'

set nocount on
create table #pagos(
	fecha smalldatetime,
	codprestamo varchar(25),
	monto money
)
insert into #pagos
select fecha,codigocuenta codprestamo,montointerestran
from tcstransacciondiaria with(nolock)
where codsistema='CA'
and fecha>=@fecini
and fecha<=@fecfin
and tipotransacnivel3 in(104,105)
--21,213

create table #pa(
	fecha smalldatetime,
	codprestamo varchar(25),
	monto money,
	nrodiasatraso int,
	codasesor varchar(15),
	tiporeprog varchar(15)
)
insert into #pa
select p.fecha,p.codprestamo,p.monto,isnull(c.nrodiasatraso,cx.nrodiasatraso) nrodiasatraso,isnull(c.codasesor,cx.codasesor) codasesor
,isnull(c.tiporeprog,cx.tiporeprog) tiporeprog
from #pagos p with(nolock)
left outer join tcscartera c with(nolock) on p.fecha-1=c.fecha and p.codprestamo=c.codprestamo
left outer join tcscartera cx with(nolock) on p.fecha=cx.fecha and p.codprestamo=cx.codprestamo

delete from #pa where nrodiasatraso>=90
delete from #pa where tiporeprog='REEST'

--select pa.*,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else e.codusuario end Ncodasesor
delete from #pa
from #pa pa
left outer join tcsempleadosfecha e on e.codusuario=pa.codasesor and e.fecha=pa.fecha
where (case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else e.codusuario end)='HUERFANO'

select codasesor,sum(monto) monto
from #pa
group by codasesor

drop table #pagos
drop table #pa
GO