SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACsRepVencimientos]
as
set nocount on

declare @Fecha smalldatetime
select @Fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @FecIni smalldatetime
declare @FecFin smalldatetime

if (datepart(weekday,@Fecha+1)=1)
begin
	print '1'
	truncate table tCsARepVencimientos
	return
end
if (datepart(weekday,@Fecha+1)=7)
begin
	print '1'
	truncate table tCsARepVencimientos
	return
end
if (datepart(weekday,@Fecha+1)=6)
begin
	set @FecIni=@Fecha+4
	set @FecFin=@Fecha+4
end
else
begin
	set @FecIni=@Fecha+2
	set @FecFin=@Fecha+2
end
--select @FecFin

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231','98') --and tiporeprog='SINRE'
and codprestamo not in (select codprestamo from tCsCarteraAlta)

select distinct codprestamo
into #CA
from tCsPadronPlanCuotas with(nolock)
where fechavencimiento=@FecFin and fecha=@fecha and codprestamo in(select codprestamo from #ptmos)

select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto,c.MontoCuota,            
c.MontoDevengado,c.MontoPagado,c.MontoCondonado,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo
into #Saldos
from tcspadronplancuotas c with(nolock)
where c.codprestamo in (select codprestamo from #ca)

select codprestamo,sum(monto) monto
into #PagoHoy
from (
	select codprestamo, isnull(sum(Saldo),0) monto
	from #Saldos
	where Saldo > 0 and fechavencimiento<=@Fecha
	group by codprestamo
) a
group by codprestamo

truncate table tCsARepVencimientos

insert into tCsARepVencimientos
SELECT @fecfin fecha,o.CodOficina,o.NomOficina AS sucursal
,c.CodPrestamo,u.nombrecompleto cliente,isnull(u.telefonomovil,'') telefonomovil
,c.nrodiasatraso,c.cuotaactual
,a.MontoCuota,c.FechaDesembolso 
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombrecompleto end promotor
,case when c.nrodiasatraso >=31 then '31+' else '0-30' end rangoMora
,isnull(ph.monto,0) 'SaldoPonerCorriente'
--into tCsARepVencimientos
FROM tCsCarteraDet d with(nolock)
INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
INNER JOIN tClOficinas o with(nolock) ON c.CodOficina=o.CodOficina
inner JOIN tcspadronclientes u with(nolock) on u.codusuario=d.codusuario
LEFT OUTER JOIN tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
LEFT OUTER JOIN tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
INNER JOIN (
	SELECT CodPrestamo, CodUsuario,sum(Montocuota) Montocuota
	FROM tCsPadronPlanCuotas with(nolock)
	where codconcepto in('CAPI','INTE','IVAIT','SDV') and seccuota=1
	GROUP BY CodPrestamo, CodUsuario
) a ON d.CodPrestamo=a.CodPrestamo AND d.CodUsuario=a.CodUsuario
left outer join #PagoHoy ph on ph.codprestamo=d.codprestamo
WHERE (d.Fecha=@Fecha) AND (c.cartera='ACTIVA') --AND c.CODOFICINA='309'
and c.nrodiasatraso<=7
and c.codprestamo in(select codprestamo from #CA)

drop table #CA
drop table #ptmos
drop table #Saldos
drop table #PagoHoy
GO