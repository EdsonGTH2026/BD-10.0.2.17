SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaPICaClientesxDiaAtraso] @codoficina varchar(500),@codasesor varchar(15),@diasini int,@diasfin int
as
set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

/*
declare @codoficina varchar(500)
set @codoficina='15'
declare @codasesor varchar(15)
set @codasesor=''
declare @diasini int
declare @diasfin int
set @diasini=1
set @diasfin=7
*/

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

--select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto,c.MontoCuota,            
--c.MontoDevengado,c.MontoPagado,c.MontoCondonado,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo
--into #Saldos
--from tcspadronplancuotas c with(nolock)
--where c.codprestamo in (select codprestamo from #ptmos)

----select * from #Saldos
--select codprestamo,sum(monto) monto
--into #PagoHoy
--from (
--	select codprestamo, isnull(sum(Saldo),0) monto
--	from #Saldos
--	where fechavencimiento<=@Fecha+1--'20190411'
--	group by codprestamo

--) a
--group by codprestamo


SELECT c.codprestamo,cl.nombrecompleto cliente
,cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.interesctaorden+cd.moratoriovigente+cd.moratoriovencido+cd.moratorioctaorden+cd.impuestos+cd.otroscargos+cd.cargomora deuda
,c.nrodiasatraso,cl.telefonomovil
--,c.codasesor
,dc.SaldoPonerCorriente 'SaldoPonerCorriente'
FROM tCsCartera c with(nolock)
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
inner join tcspadronclientes cl with(nolock) on cl.codusuario=cd.codusuario
--left outer join #PagoHoy ph on ph.codprestamo=c.codprestamo
left outer join tCsADatosCliCarteraActiva dc with(nolock) on dc.codprestamo=c.codprestamo
where c.fecha=@fecha and c.cartera='ACTIVA'
and c.codprestamo in(select codprestamo from #ptmos)
and (c.codasesor=@codasesor or @codasesor='' or @codasesor is null)
and c.NroDiasAtraso>=@diasini and c.NroDiasAtraso<=@diasfin

drop table #ptmos
--drop table #PagoHoy
--drop table #Saldos
GO