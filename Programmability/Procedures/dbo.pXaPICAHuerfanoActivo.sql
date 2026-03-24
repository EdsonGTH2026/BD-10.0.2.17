SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaPICAHuerfanoActivo
CREATE procedure [dbo].[pXaPICAHuerfanoActivo]
as
set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select c.codprestamo
from tcscartera c with(nolock)
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
where c.fecha=@fecha and c.cartera='ACTIVA' and c.codoficina not in('97','230','231')
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by c.fecha,c.codprestamo

select fecha,promotor
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0a30nroptmo) D0a30nroptmo,sum(D0a30saldo) D0a30saldo, (case when sum(saldocapital)=0 then 0 else sum(D0a30saldo)/sum(saldocapital) end)*100 D0a30Por
,count(distinct D31mnroptmo) D31mnroptmo,sum(D31msaldo) D31msaldo, (case when sum(saldocapital)=0 then 0 else sum(D31msaldo)/sum(saldocapital) end)*100 D31mPor
from (
  SELECT --cl.nombrecompleto promotor
  case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else 'ACTIVA' end promotor
  ,c.Fecha,cd.codusuario,c.CodPrestamo
  ,cd.saldocapital
  ,case when c.Estado<>'VENCIDO' then
	case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.codprestamo else null end
   else null end D0a30nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end
   else 0 end D0a30saldo
  ,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31mnroptmo
  ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31msaldo
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  --inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
	and c.codoficina<>'98'
) a
group by fecha,promotor

drop table #ptmos
GO