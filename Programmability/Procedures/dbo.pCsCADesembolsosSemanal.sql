SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCADesembolsosSemanal] @fecha smalldatetime
as
declare @periodo varchar(6)
set @periodo=dbo.fdufechaaperiodo(@fecha)

create table #tse(
  region varchar(200),
  nrosemana int,
  fechaini smalldatetime,
  fechafin smalldatetime,
  nro_nuevo int default(0),
  nro_nuevoptmo int default(0),
  mto_nuevo decimal(16,2) default(0),
  nro_renov int default(0),
  nro_renovptmo int default(0),
  mto_renov decimal(16,2) default(0),
  Cob_nro   int default(0),
  Cob_monto decimal(16,2) default(0)
)

create table #tse_tmp(
  region varchar(200),
  nrosemana int,
  fechaini smalldatetime,
  fechafin smalldatetime,
  nro_nuevo int,
  nro_nuevoptmo int default(0),
  mto_nuevo decimal(16,2),
  nro_renov int,
  nro_renovptmo int default(0),
  mto_renov decimal(16,2)
)

insert into #tse (region,nrosemana,fechaini,fechafin,Cob_nro,Cob_monto)
select z.Nombre 'Centro Regional',s.nrosemana,s.fechaini,s.fechafin
--,t.codigocuenta,t.codoficina
,count(distinct(t.codigocuenta)) nro
,sum(t.montocapitaltran) monto
from tcstransacciondiaria t with(nolock)
inner join tcscartera c with(nolock) on isnull(c.fecha,dateadd(day,-1,c.fecha))=t.fecha and c.codprestamo=t.codigocuenta
inner join (select * from fduTablaSemanaPeriodosFC(@periodo)) s
on t.fecha>=s.fechaini and t.fecha<=s.fechafin
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where t.codsistema='CA' and t.tipotransacnivel1='I'
and t.codoficina<'97' and t.extornado=0
and c.cartera='ACTIVA'
group by z.Nombre,s.nrosemana,s.fechaini,s.fechafin
order by z.Nombre,s.nrosemana
--6953
--6126

insert into #tse_tmp
select z.Nombre 'Centro Regional',s.nrosemana,s.fechaini,s.fechafin
,count(distinct(case when p.secuenciacliente=1 then p.codusuario else null end)) nro_nuevo
,count(distinct(case when p.secuenciacliente=1 then p.codprestamo else null end)) nro_nuevoptmo
,sum(case when p.secuenciacliente=1 then p.monto else 0 end) mto_nuevo
,count(distinct(case when p.secuenciacliente<>1 then p.codusuario else null end)) nro_renov
,count(distinct(case when p.secuenciacliente<>1 then p.codprestamo else null end)) nro_renovptmo
,sum(case when p.secuenciacliente<>1 then p.monto else 0 end) mto_renov
from tcspadroncarteradet p with(nolock)
inner join (select * from fduTablaSemanaPeriodosFC(@periodo)) s
on p.desembolso>=s.fechaini and p.desembolso<=s.fechafin
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where carteraactual<>'ADMINISTRATIVA' and p.codoficina<'97'
group by z.Nombre,s.nrosemana,s.fechaini,s.fechafin
order by z.Nombre,s.nrosemana

update #tse
set nro_nuevo=t.nro_nuevo,mto_nuevo=t.mto_nuevo,nro_renov=t.nro_renov,mto_renov=t.mto_renov
,nro_nuevoptmo=t.nro_nuevoptmo,nro_renovptmo=t.nro_renovptmo
from #tse s
inner join #tse_tmp t 
on s.region=t.region and s.nrosemana=t.nrosemana and s.fechaini=t.fechaini and s.fechafin=t.fechafin

insert into #tse (region,nrosemana,fechaini,fechafin,nro_nuevo,mto_nuevo,nro_renov,mto_renov)
select t.region,t.nrosemana,t.fechaini,t.fechafin
,t.nro_nuevo,t.mto_nuevo,t.nro_renov,t.mto_renov
from #tse s
right outer join #tse_tmp t
--left outer join #tse_tmp t
on s.region=t.region and s.nrosemana=t.nrosemana and s.fechaini=t.fechaini and s.fechafin=t.fechafin
where s.region is null

select * from #tse

drop table #tse
drop table #tse_tmp
GO