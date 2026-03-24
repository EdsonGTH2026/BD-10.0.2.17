SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCADesembolsosSemanalComunal] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha ='20140521'
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
  
  comu_nro_nuevo int default(0),
  comu_nro_nuevoptmo int default(0),
  comu_mto_nuevo decimal(16,2) default(0),
  comu_nro_renov int default(0),
  comu_nro_renovptmo int default(0),
  comu_mto_renov decimal(16,2) default(0)
)

insert into #tse
select z.Nombre 'Centro Regional',s.nrosemana,s.fechaini,s.fechafin
,count(distinct(case when p.codproducto<>'164' then (case when p.secuenciacliente=1 then p.codusuario else null end) else null end)) nro_nuevo
,count(distinct(case when p.codproducto<>'164' then (case when p.secuenciacliente=1 then p.codprestamo else null end) else null end)) nro_nuevoptmo
,sum(case when p.codproducto<>'164' then (case when p.secuenciacliente=1 then p.monto else 0 end) else 0 end) mto_nuevo
,count(distinct(case when p.codproducto<>'164' then (case when p.secuenciacliente<>1 then p.codusuario else null end) else null end)) nro_renov
,count(distinct(case when p.codproducto<>'164' then (case when p.secuenciacliente<>1 then p.codprestamo else null end) else null end)) nro_renovptmo
,sum(case when p.codproducto<>'164' then (case when p.secuenciacliente<>1 then p.monto else 0 end) else 0 end) mto_renov

,count(distinct(case when p.codproducto='164' then (case when p.secuenciacliente=1 then p.codusuario else null end) else null end)) comu_nro_nuevo
,count(distinct(case when p.codproducto='164' then (case when p.secuenciacliente=1 then p.codprestamo else null end) else null end)) comu_nro_nuevoptmo
,sum(case when p.codproducto='164' then (case when p.secuenciacliente=1 then p.monto else 0 end) else 0 end) comu_mto_nuevo
,count(distinct(case when p.codproducto='164' then (case when p.secuenciacliente<>1 then p.codusuario else null end) else null end)) comu_nro_renov
,count(distinct(case when p.codproducto='164' then (case when p.secuenciacliente<>1 then p.codprestamo else null end) else null end)) comu_nro_renovptmo
,sum(case when p.codproducto='164' then (case when p.secuenciacliente<>1 then p.monto else 0 end) else 0 end) comu_mto_renov
from tcspadroncarteradet p with(nolock)
inner join (select * from fduTablaSemanaPeriodosFC(@periodo)) s
on p.desembolso>=s.fechaini and p.desembolso<=s.fechafin
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona 
where carteraactual<>'ADMINISTRATIVA' and p.codoficina<'97'
group by z.Nombre,s.nrosemana,s.fechaini,s.fechafin 
order by z.Nombre,s.nrosemana

select *,cast(0 as int) Cob_nro,cast(0 as decimal(16,2)) Cob_monto from #tse

drop table #tse
GO