SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCADesembolsosSemanalCruzada] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20140520'

declare @periodo varchar(6)
set @periodo=dbo.fdufechaaperiodo(@fecha)

create table #tse(
  region varchar(200),
  sucursal varchar(200),
  nrosemana int,
  fechaini smalldatetime,
  fechafin smalldatetime,
  nro_nuevo int default(0),
  nro_nuevoptmo int default(0),
  mto_nuevo decimal(16,2) default(0),
  nro_renov int default(0),
  nro_renovptmo int default(0),
  mto_renov decimal(16,2) default(0)
)


insert into #tse
select z.Nombre 'Centro Regional',replicate('0',2-len(ltrim(rtrim(o.codoficina)))) + ltrim(rtrim(o.codoficina)) + ' ' + o.nomoficina,s.nrosemana,s.fechaini,s.fechafin
,count(distinct(case when p.secuenciacliente=1 then p.codusuario else null end)) nro_nuevo
,count(distinct(case when p.secuenciacliente=1 then p.codprestamo else null end)) nro_nuevoptmo
,sum(case when p.secuenciacliente=1 then p.monto else 0 end) mto_nuevo
,count(distinct(case when p.secuenciacliente<>1 then p.codusuario else null end)) nro_renov
,count(distinct(case when p.secuenciacliente<>1 then p.codprestamo else null end)) nro_renovptmo
,sum(case when p.secuenciacliente<>1 then p.monto else 0 end) mto_renov
from tcspadroncarteradet p with(nolock)
--inner join (select * from fduTablaSemanaPeriodosfc('201301,201302,201303,201304,201305,201306,201307,201308,201309,201310,201311,201312')) s --@periodo
inner join (select * from fduTablaSemanaPeriodosfc(@periodo)) s
on p.desembolso>=s.fechaini and p.desembolso<=s.fechafin
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where carteraactual<>'ADMINISTRATIVA' and p.codoficina<'97'
group by z.Nombre,o.codoficina,o.nomoficina,s.nrosemana,s.fechaini,s.fechafin
order by z.Nombre,s.nrosemana

select * from #tse
order by nrosemana

drop table #tse
GO