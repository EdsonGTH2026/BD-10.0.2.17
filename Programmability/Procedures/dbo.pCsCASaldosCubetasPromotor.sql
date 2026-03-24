SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCASaldosCubetasPromotor]
as
set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select c.codprestamo
from tcscartera c with(nolock)
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
where c.cartera='ACTIVA' and c.codoficina not in('97','230','231')
and c.codprestamo not in (select codprestamo from tCsCarteraAlta)
and o.tipo<>'Cerrada' --Comentar esta linea para incluir sucursales cerradas
and c.fecha=@fecha
group by c.fecha,c.codprestamo

truncate table tCsACaSaldosCubPromotor

insert into tCsACaSaldosCubPromotor
select fecha,sucursal,promotor
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo, (case when sum(saldocapital)=0 then 0 else sum(D0saldo)/sum(saldocapital) end)*100 D0Por
,count(distinct D1a7nroptmo) D1a7nroptmo,sum(D1a7saldo) D1a7saldo, (case when sum(saldocapital)=0 then 0 else sum(D1a7saldo)/sum(saldocapital) end)*100 D1a7Por
,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo, (case when sum(saldocapital)=0 then 0 else sum(D8a15saldo)/sum(saldocapital) end)*100 D8a15Por
,count(distinct D16a30nroptmo) D16a30nroptmo,sum(D16a30saldo) D16a30saldo, (case when sum(saldocapital)=0 then 0 else sum(D16a30saldo)/sum(saldocapital) end)*100 D16a30Por
,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo, (case when sum(saldocapital)=0 then 0 else sum(D31a60saldo)/sum(saldocapital) end)*100 D31a60Por
,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo, (case when sum(saldocapital)=0 then 0 else sum(D61a89saldo)/sum(saldocapital) end)*100 D61a89Por
,count(distinct D90a239nroptmo) D90a239nroptmo,sum(D90a239saldo) D90a239saldo, (case when sum(saldocapital)=0 then 0 else sum(D90a239saldo)/sum(saldocapital) end)*100 D90a239Por
,count(distinct Dm240nroptmo) Dm240nroptmo,sum(Dm240saldo) Dm240saldo, (case when sum(saldocapital)=0 then 0 else sum(Dm240saldo)/sum(saldocapital) end)*100 Dm240Por
--into tCsACaSaldosCubPromotor
from (
  SELECT --cl.nombrecompleto promotor
  case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombrecompleto end promotor
  ,o.nomoficina sucursal,c.Fecha, c.cartera tipo
  ,cd.codusuario,c.CodPrestamo
  ,cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.interesctaorden+cd.moratoriovigente+cd.moratoriovencido+cd.moratorioctaorden+cd.impuestos+cd.otroscargos+cd.cargomora deuda
  ,cd.saldocapital
  ,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso=0 then cd.codprestamo else null end
   else null end D0nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end
   else 0 end D0saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end
   else null end D1a7nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end
   else 0 end D1a7saldo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end
   else null end D8a15nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end
   else 0 end D8a15saldo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end
   else null end D16a30nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end
   else 0 end D16a30saldo
  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end D31a60nroptmo
  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end D31a60saldo
,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end D61a89nroptmo
  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end D61a89saldo
  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=239 then cd.codprestamo else null end D90a239nroptmo
  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=239 then cd.saldocapital else 0 end D90a239saldo
  ,case when c.NroDiasAtraso>=240 then cd.codprestamo else null end Dm240nroptmo
  ,case when c.NroDiasAtraso>=240 then cd.saldocapital else 0 end Dm240saldo
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
  left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
) a
group by fecha,sucursal,promotor

drop table #ptmos


GO