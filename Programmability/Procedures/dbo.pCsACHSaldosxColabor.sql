SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsACHSaldosxColabor
CREATE procedure [dbo].[pCsACHSaldosxColabor] @fecha smalldatetime
as 
--declare @fecha smalldatetime
--set @fecha='20141111'

create table #tmp(
  fecha smalldatetime,
  tipo varchar(100),
  region varchar(200),
  sucursal varchar(200),
  nroclientes decimal(16,2) default(0),
  saldocartera decimal(16,2) default(0),
  nropromotores decimal(16,2) default(0),
  nroempleados decimal(16,2) default(0),
  npxclientes as cast(case when nropromotores=0 then 0 else nroclientes/nropromotores end as decimal(16,2)), --decimal(16,2),
  nexclientes as cast(case when nroempleados=0 then 0 else nroclientes/nroempleados end as decimal(16,2)),--decimal(16,2),
  npxsaldocartera as cast(case when nropromotores=0 then 0 else saldocartera/nropromotores end as decimal(16,2)),--decimal(16,2),
  nexsaldocartera as cast(case when nroempleados=0 then 0 else saldocartera/nroempleados end as decimal(16,2)),--decimal(16,2)
  imor decimal(16,2) default(0),
  npximor as cast(case when nropromotores=0 then 0 else imor/nropromotores end as decimal(16,2)),--decimal(16,2),
  neximor as cast(case when nroempleados=0 then 0 else imor/nroempleados end as decimal(16,2))--decimal(16,2)
)

insert into #tmp (fecha,tipo,region,sucursal,nroclientes,saldocartera,imor)
select fecha,tipo,region,sucursal
,count(distinct codusuario) nroclie
,sum(t_saldo) saldocartera
,(sum(saldovencido)/sum(t_saldo))*100 imor
from (
  SELECT c.Fecha,case when o.tipo='Cerrada' then 'CERRADAS' ELSE 'ACTIVAS' END tipo
  ,replicate('0',2-len(isnull(ce.CodOficina,c.codoficina))) + rtrim(isnull(ce.CodOficina,c.codoficina)) + ' ' + o.nomoficina sucursal
  ,cd.codusuario,c.CodPrestamo
  ,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido t_saldo
  ,z.nombre region
  ,case when c.estado='VENCIDO' then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end saldovencido
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  left outer join tcscarterasuce ce with(nolock) on c.codprestamo=ce.codprestamo
  left outer join tcloficinas o with(nolock) on o.codoficina=isnull(ce.codoficina,c.codoficina)
  left outer join tclzona z with(nolock) on z.zona=o.zona
  where c.fecha=@fecha and c.cartera='ACTIVA'
) a
group by fecha,tipo,sucursal,region

update #tmp
set nropromotores=a.promotores,nroempleados=a.empleados
from #tmp x
inner join (
  select codoficinanom
  ,replicate('0',2-len(codoficinanom)) + rtrim(codoficinanom) + ' ' + o.nomoficina sucursal
  ,sum(case when codpuesto in (67,66) then 1 else 0 end) promotores
  ,count(codoficinanom) empleados
  from tcsempleados
  left outer join tcloficinas o with(nolock) on o.codoficina=codoficinanom
  where estado=1 and codoficinanom<>'98' and ingreso<=@fecha
  group by codoficinanom,o.nomoficina
) a on a.sucursal=x.sucursal

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsRptCHSaldosxColabor]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].tCsRptCHSaldosxColabor

select * 
into tCsRptCHSaldosxColabor
from #tmp

drop table #tmp
GO