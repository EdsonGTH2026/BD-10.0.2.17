SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pXaPICaSaldosIniVs2
CREATE procedure [dbo].[pXaPICaSaldosIniVs2] @codoficina varchar(2000)
as
set nocount on

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecha=@fecini-1

--declare @codoficina varchar(500)
--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and codoficina in(select codigo from @sucursales)

select --sucursal,--,count(distinct codusuario) nroclie
count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,sum(saldocartera) saldocartera
,sum(deuda) saldodeuda
,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo, (sum(D0saldo)/sum(saldocapital))*100 D0Por
,count(distinct D1a7nroptmo) D1a7nroptmo,sum(D1a7saldo) D1a7saldo, (sum(D1a7saldo)/sum(saldocapital))*100 D1a7Por
,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo, (sum(D8a15saldo)/sum(saldocapital))*100 D8a15Por
,count(distinct D16a30nroptmo) D16a30nroptmo,sum(D16a30saldo) D16a30saldo, (sum(D16a30saldo)/sum(saldocapital))*100 D16a30Por
,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo, (sum(D31a60saldo)/sum(saldocapital))*100 D31a60Por
,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo, (sum(D61a89saldo)/sum(saldocapital))*100 D61a89Por
,count(distinct D90a239nroptmo) D90a239nroptmo,sum(D90a239saldo) D90a239saldo, (sum(D90a239saldo)/sum(saldocapital))*100 D90a239Por
,count(distinct Dm240nroptmo) Dm240nroptmo,sum(Dm240saldo) Dm240saldo, (sum(Dm240saldo)/sum(saldocapital))*100 DM240Por
,count(distinct Progrenroptmo) Progrenroptmo,sum(Progresaldo) Progresaldo, (sum(Progresaldo)/sum(saldocapital))*100 ProgrePor
,count(distinct Propionroptmo) Propionroptmo,sum(Propiosaldo) Propiosaldo, (sum(Propiosaldo)/sum(saldocapital))*100 PropioPor

,count(distinct D0a90nroptmo) D0a90nroptmo,sum(D0a90saldo) D0a90saldo, (sum(D0a90saldo)/sum(saldocapital))*100 D0a90Por
,count(distinct DM90nroptmo) DM90nroptmo,sum(DM90saldo) DM90saldo, (sum(DM90saldo)/sum(saldocapital))*100 DM90Por

from (
  SELECT c.Fecha, c.cartera tipo--case when o.tipo='Cerrada' then 'CERRADAS' ELSE 'ACTIVAS' END tipo
  --,replicate('0',2-len(c.CodOficina)) + rtrim(c.CodOficina) + ' ' + o.nomoficina sucursal
  ,cd.codusuario,c.CodPrestamo
  ,cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.interesctaorden+cd.moratoriovigente+cd.moratoriovencido+cd.moratorioctaorden+cd.impuestos+cd.otroscargos+cd.cargomora deuda
  ,cd.saldocapital
  ,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso=0 then cd.codprestamo else null end
   else null end D0nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso=0 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end
   else 0 end D0saldo

  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end
   else null end D1a7nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7
    then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end else 0 end D1a7saldo
  
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end
   else null end D8a15nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15
    then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end else 0 end D8a15saldo

  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end
   else null end D16a30nroptmo
  ,case when c.Estado<>'VENCIDO' then
    case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30
    then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end
   else 0 end D16a30saldo

  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end D31a60nroptmo
  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D31a60saldo

  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end D61a89nroptmo
  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D61a89saldo

  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=239 then cd.codprestamo else null end D90a239nroptmo
  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=239 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D90a239saldo

  ,case when c.NroDiasAtraso>=240 then cd.codprestamo else null end Dm240nroptmo
  ,case when c.NroDiasAtraso>=240 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end Dm240saldo

  ,case when c.codfondo=20 then cd.codprestamo else null end Progrenroptmo
  ,case when c.codfondo=20 then cd.saldocapital*0.7 else 0 end Progresaldo

  ,case when c.codfondo<>20 then cd.codprestamo else null end Propionroptmo
  ,case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end Propiosaldo

  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=90 then cd.codprestamo else null end D0a90nroptmo
  ,case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=90 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D0a90saldo

  ,case when c.NroDiasAtraso>=91 then cd.codprestamo else null end DM90nroptmo
  ,case when c.NroDiasAtraso>=91 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end DM90saldo

  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)
) a

drop table #ptmos
GO