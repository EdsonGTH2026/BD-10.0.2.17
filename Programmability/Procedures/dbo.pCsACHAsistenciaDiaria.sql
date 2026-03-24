SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsACHAsistenciaDiaria
--exec pCsACHAsistenciaDiaria '20140605'
create procedure [dbo].[pCsACHAsistenciaDiaria] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20140602'

declare @periodo varchar(6)
set @periodo=dbo.fdufechaaperiodo(@fecha)

create table #feriados(fechferiado smalldatetime)

insert into #feriados
select distinct fechferiado from [10.0.2.14].[Finmas].[dbo].[tClFeriados] where fechferiado=@fecha

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsRptCHAsistenciaDiaria]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].tCsRptCHAsistenciaDiaria

select d.dia,co.codempleado,co.nombre,co.nomoficina,co.entrada,co.salida,co.tatrazo,co.puesto
,case when DATENAME(weekday, d.dia )='Sunday' then 'Domingo' else 
    case when fe.fechferiado is null then 'Laboral' else 'Feriado' end
  end TipoDia
,case when co.salida is null then 'F' else 'X' end Falta
into tCsRptCHAsistenciaDiaria
from dbo.fduTablaFechas(@periodo) d
left outer join (
  SELECT e.codempleado,cl.nombrecompleto Nombre,o.nomoficina,c.fecha
  ,c.entrada,c.salida,c.tatrazo,p.Descripcion puesto
  FROM tCsRhControl c
  inner join tcsempleados e on e.codusuario=c.codusuario
  inner join tcspadronclientes cl on cl.codusuario=c.codusuario
  inner join tcloficinas o on o.codoficina=e.codoficinanom
  inner join tcsclpuestos p on p.codigo=e.codpuesto
  where c.fecha>=@fecha and c.fecha<=@fecha
  --and c.codusuario in('UMC1809791','GGH0306701','AOY0801881')
) co on d.dia=co.fecha
left outer join #feriados fe on fe.fechferiado=d.dia
where d.dia=@fecha
order by co.nombre,d.dia

drop table #feriados
GO