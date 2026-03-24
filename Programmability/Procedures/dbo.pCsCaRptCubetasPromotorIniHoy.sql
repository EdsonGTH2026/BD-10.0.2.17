SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptCubetasPromotorIniHoy] @codoficina varchar(2000)
as
set nocount on
--declare @codoficina varchar(500)
--set @codoficina='37'

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecini=@fecini-1

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecini
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from @sucursales)

create table #cu(
	fecha smalldatetime,
	sucursal varchar(200),
	promotor varchar(300),
	antiguedad int,
	ini_nroptmo int,
	ini_saldocapital money,
	ini_VigenteNro int,
	ini_VigenteSaldo money,
	ini_VigentePor money,
	ini_AtrasoNro int,
	ini_AtrasoSaldo money,
	ini_AtrasoPor money,
	ini_VencidoNro int,
	ini_VencidoSaldo money,
	ini_VencidoPor money,

	hoy_nroptmo int,
	hoy_saldocapital money,
	hoy_VigenteNro int,
	hoy_VigenteSaldo money,
	hoy_VigentePor money,
	hoy_AtrasoNro int,
	hoy_AtrasoSaldo money,
	hoy_AtrasoPor money,
	hoy_VencidoNro int,
	hoy_VencidoSaldo money,
	hoy_VencidoPor money
)

insert into #cu
(fecha,sucursal,promotor,antiguedad,ini_nroptmo,ini_saldocapital,ini_VigenteNro,ini_VigenteSaldo,ini_VigentePor,ini_AtrasoNro,ini_AtrasoSaldo,ini_AtrasoPor,ini_VencidoNro,ini_VencidoSaldo,ini_VencidoPor)
select @fecha fecha,sucursal,promotor,max(antiguedad) antiguedad
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0a7nroptmo) VigenteNro,sum(D0a7saldo) VigenteSaldo, (sum(D0a7saldo)/sum(saldocapital))*100 VigentePor
,count(distinct D8a30nroptmo) AtrasoNro,sum(D8a30saldo) AtrasoSaldo, (sum(D8a30saldo)/sum(saldocapital))*100 AtrasoPor
,count(distinct D31nroptmo) VencidoNro,sum(D31saldo) VencidoSaldo, (sum(D31saldo)/sum(saldocapital))*100 VencidoPor
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
  ,cd.saldocapital
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D0a7nroptmo
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D0a7saldo

  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D8a30nroptmo
  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D8a30saldo

  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31nroptmo
  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31saldo
  --,cl.nombrecompleto promotor
  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombres +' '+ cl.paterno end promotor
  ,datediff(month,ex.ingreso,@fecha) antiguedad
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
  left outer join tcsempleados ex on ex.codusuario=c.codasesor
  where c.fecha=@fecini and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
	
) a
group by sucursal,promotor

truncate table #ptmos
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from @sucursales)

select @fecha fecha,sucursal,promotor,max(antiguedad) antiguedad
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0a7nroptmo) VigenteNro,sum(D0a7saldo) VigenteSaldo, (sum(D0a7saldo)/sum(saldocapital))*100 VigentePor
,count(distinct D8a30nroptmo) AtrasoNro,sum(D8a30saldo) AtrasoSaldo, (sum(D8a30saldo)/sum(saldocapital))*100 AtrasoPor
,count(distinct D31nroptmo) VencidoNro,sum(D31saldo) VencidoSaldo, (sum(D31saldo)/sum(saldocapital))*100 VencidoPor
into #hoy
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
  ,cd.saldocapital
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D0a7nroptmo
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D0a7saldo

  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D8a30nroptmo
  ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D8a30saldo

  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31nroptmo
  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31saldo
  --,cl.nombrecompleto promotor
  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombres +' '+ cl.paterno end promotor
  ,datediff(month,ex.ingreso,@fecha) antiguedad
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
  left outer join tcsempleados ex on ex.codusuario=c.codasesor
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
	
) a
group by sucursal,promotor

insert into #cu
(fecha,sucursal,promotor)
select fecha,sucursal,promotor
from #hoy
where promotor not in(select promotor from #cu)

update #cu
set hoy_nroptmo=nroptmo,hoy_saldocapital=saldocapital,hoy_VigenteNro=VigenteNro,hoy_VigenteSaldo=VigenteSaldo,hoy_VigentePor=VigentePor
,hoy_AtrasoNro=AtrasoNro,hoy_AtrasoSaldo=AtrasoSaldo,hoy_AtrasoPor=AtrasoPor,hoy_VencidoNro=VencidoNro,hoy_VencidoSaldo=VencidoSaldo,hoy_VencidoPor=VencidoPor
from #cu c
inner join #hoy h on c.promotor=h.promotor

select *
from #cu

drop table #ptmos
drop table #cu
drop table #hoy

GO