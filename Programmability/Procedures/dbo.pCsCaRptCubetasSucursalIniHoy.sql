SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsCaRptCubetasSucursalIniHoy '101,107,108,120,139,301,307,308,320,339,432,434'
CREATE procedure [dbo].[pCsCaRptCubetasSucursalIniHoy] @codoficina varchar(2000)
as
set nocount on
--declare @codoficina varchar(2000)
--set @codoficina='101,107,108,120,139,301,307,308,320,339,432,434'

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
	sucursal varchar(300),
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
(fecha,sucursal,ini_nroptmo,ini_saldocapital,ini_VigenteNro,ini_VigenteSaldo,ini_VigentePor,ini_AtrasoNro,ini_AtrasoSaldo,ini_AtrasoPor,ini_VencidoNro,ini_VencidoSaldo,ini_VencidoPor)
select @fecha fecha,sucursal
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
  ,z.nombre region
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  inner join tclzona z with(nolock) on z.zona=o.zona
  where c.fecha=@fecini and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
) a
group by sucursal

insert into #cu
(fecha,sucursal,ini_nroptmo,ini_saldocapital,ini_VigenteNro,ini_VigenteSaldo,ini_VigentePor,ini_AtrasoNro,ini_AtrasoSaldo,ini_AtrasoPor,ini_VencidoNro,ini_VencidoSaldo,ini_VencidoPor)
select @fecini,x.nomoficina sucursal,0 ini_nroptmo,0 ini_saldocapital,0 ini_VigenteNro,0 ini_VigenteSaldo,0 ini_VigentePor,0 ini_AtrasoNro,0 ini_AtrasoSaldo
,0 ini_AtrasoPor,0 ini_VencidoNro,0 ini_VencidoSaldo,0 ini_VencidoPor
from #cu c
right outer join (
	select distinct nomoficina from tcloficinas o with(nolock)
	where codoficina in (select codigo from @sucursales)
) x on c.sucursal=x.nomoficina
where c.sucursal is null

truncate table #ptmos
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codoficina in(select codigo from @sucursales)

select @fecha fecha,sucursal
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
  ,z.nombre region
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  inner join tclzona z with(nolock) on z.zona=o.zona
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)	
) a
group by sucursal

update #cu
set hoy_nroptmo=nroptmo,hoy_saldocapital=saldocapital,hoy_VigenteNro=VigenteNro,hoy_VigenteSaldo=VigenteSaldo,hoy_VigentePor=VigentePor
,hoy_AtrasoNro=AtrasoNro,hoy_AtrasoSaldo=AtrasoSaldo,hoy_AtrasoPor=AtrasoPor,hoy_VencidoNro=VencidoNro,hoy_VencidoSaldo=VencidoSaldo,hoy_VencidoPor=VencidoPor
from #cu c
inner join #hoy h on c.sucursal=h.sucursal

select *
from #cu

drop table #ptmos
drop table #cu
drop table #hoy

GO