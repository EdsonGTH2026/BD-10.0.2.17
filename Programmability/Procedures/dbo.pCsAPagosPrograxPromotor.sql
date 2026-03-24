SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsAPagosPrograxPromotor]
as
set nocount on
set ansi_warnings off
declare @fecha smalldatetime
--set @fecha='20180930'
select @fecha = fechaconsolidacion from vCsFechaconsolidacion

create table #ca (codprestamo varchar(25),cuotas int)
insert into #ca
select distinct c.codprestamo,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end
from tcscartera c with(nolock)
inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.fechadesembolso
where c.fecha=@fecha
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in('97','230','231')
and c.cartera='ACTIVA' 

--and c.codprestamo in(
--'307-170-06-00-05010'
--)

--create table #ptmos (codprestamo varchar(25))
--insert into #ptmos
--select distinct codprestamo 
--from tcscartera with(nolock)
--where fecha=@fecha and cartera='ACTIVA' and codoficina not in('97','230','231')
--and codprestamo not in (select codprestamo from tCsCarteraAlta)
--and codprestamo in(
--	--select codprestamo from tcspadronplancuotas with(nolock)
--	--where numeroplan=0 and seccuota>0 and fechavencimiento>=@fecha+1 and fechavencimiento<=@fecha+1
--	--and estadocuota<>'CANCELADO'
--	--group by codprestamo
--)
--and codoficina=307 --MOSSO DIAZ YONIC JESUS
--and codprestamo in(
--'307-170-06-00-04875',
--'307-170-06-06-04762'
--)
create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select p.codprestamo 
from tcspadronplancuotas p with(nolock)
inner join #ca c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas
where p.numeroplan=0 and p.seccuota>0 and p.fechavencimiento>=@fecha+1 and p.fechavencimiento<=@fecha+1
--and p.estadocuota<>'CANCELADO'
group by p.codprestamo

--select * from #ca
--select * from #ptmos

drop table #ca

select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto
,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo
into #Saldos
from tcspadronplancuotas c with(nolock)
where c.numeroplan=0 and c.seccuota>0 and c.codprestamo in (select codprestamo from #ptmos)
and estadocuota<>'CANCELADO'

--select * from #Saldos
select codprestamo,sum(monto) monto
into #PagoHoy
from (
	select codprestamo, isnull(sum(Saldo),0) monto
	from #Saldos
	where fechavencimiento<=@Fecha+1--'20190411'
	group by codprestamo
) a
group by codprestamo

--select c.CodPrestamo,sum(c.Montocuota) Montocuota
--into #MoAmor
--from tcspadronplancuotas c with(nolock)
--where c.seccuota=1 and c.numeroplan=0 and c.codprestamo in (select codprestamo from #ptmos)
--and estadocuota<>'CANCELADO'
--group by c.CodPrestamo

select codprestamo,seccuota,sum(montocuota) saldo
into #cuomo
from tcspadronplancuotas with(nolock)
where numeroplan=0 and codprestamo in (select codprestamo from #ptmos)
and estadocuota<>'CANCELADO'
group by codprestamo,seccuota

select x.codprestamo,'Montocuota'=x.saldo
into #MoAmor
from (
	select codprestamo,nro,max(saldo) saldo
	from (
		select codprestamo,count(seccuota) nro,saldo
		from #cuomo
		group by codprestamo,saldo
	) a
	group by codprestamo,nro
) x
inner join(
	select codprestamo,max(nro) nro
	from (
		select codprestamo,saldo,count(seccuota) nro
		from #cuomo
		group by codprestamo,saldo
	) b
	group by codprestamo
) c on x.nro=c.nro and x.codprestamo=c.codprestamo

select c.CodPrestamo
,count(distinct (case when c.FechaVencimiento<=@Fecha+1 then seccuota else null end)) vencidas
into #Cuo
from tcspadronplancuotas c with(nolock)
where c.numeroplan=0 and c.seccuota>0 and c.codprestamo in (select codprestamo from #ptmos)
and c.estadocuota<>'CANCELADO'
group by c.CodPrestamo

truncate table tCsACaPagosPrograxPromotor
insert into tCsACaPagosPrograxPromotor

SELECT @fecha+1 fecha,z.nombre region,c.codoficina,o.nomoficina sucursal,c.codprestamo,co.nombrecompleto promotor,cl.nombrecompleto 'NombreCliente'
,cl.telefonomovil
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then '0-7'
            when c.nrodiasatraso>=8 and c.nrodiasatraso<=30 then '8-30'
            when c.nrodiasatraso>=31 then '31+' else '' end atraso
,ma.montocuota 'amortizacion'
,isnull(ph.monto,0) 'SaldoPonerCorriente'
,cuo.vencidas cuotasvencidas
,dbo.fCaBase97('7006', '1448746',replace(c.codprestamo,'-','')) Ref_BANAMEX
,dbo.fCaBancomerReferencia(replace(c.codprestamo,'-','')) Ref_BANCOMER
--into tCsACaPagosPrograxPromotor
FROM tCsCartera c with(nolock)
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
left outer join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
left outer join #PagoHoy ph with(nolock) on ph.codprestamo=c.codprestamo
inner join #MoAmor ma with(nolock) on ma.codprestamo=c.codprestamo
left outer join #Cuo cuo with(nolock) on cuo.codprestamo=c.codprestamo
inner join tclzona z with(nolock) on z.zona=o.zona
where c.fecha=@fecha
and c.codprestamo in(select codprestamo from #ptmos)

drop table #ptmos
drop table #Saldos
drop table #PagoHoy
drop table #MoAmor
drop table #Cuo
drop table #cuomo

--select * from tCsACaPagosPrograxPromotor --1,768 / 1,318

GO