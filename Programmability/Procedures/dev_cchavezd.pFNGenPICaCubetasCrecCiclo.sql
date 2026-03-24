SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pFNGenPICaCubetasCrecCiclo

CREATE procedure [dev_cchavezd].[pFNGenPICaCubetasCrecCiclo]  
as  
set nocount on  
--declare @T1 datetime  
--declare @T2 datetime  
  
declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  

 
create table #ptmos (codprestamo varchar(25))  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecha   
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and codoficina not in('97','230','231','999')  
and cartera='ACTIVA'   
--and codoficina=304  
  
delete from FNMGConsolidado.dbo.tCACubetasxSucCiclo where fecha=@fecha    
insert into FNMGConsolidado.dbo.tCACubetasxSucCiclo  

select @fecha fecha,codoficina  
,isnull(sum(saldocapital),0) totalsaldo   
,isnull(sum(D0saldo),0) D0saldo  
,isnull(sum(D1a7saldo),0) D1a7saldo  
,isnull(sum(D8a15saldo),0) D8a15saldo  
,isnull(sum(D16a30saldo),0) D16a30saldo  
,isnull(sum(D31a60saldo),0) D31a60saldo  
,isnull(sum(D61a89saldo),0) D61a89saldo  
,isnull(sum(D90a120saldo),0) D90a120saldo  
,isnull(sum(D121a150saldo),0) D121a150saldo  
,isnull(sum(D151a180saldo),0) D151a180saldo  
,isnull(sum(D181a210saldo),0) D181a210saldo  
,isnull(sum(D211a240saldo),0) D211a240saldo  
,isnull(sum(Dm241saldo),0) Dm241saldo  
  
,isnull(sum(D0saldo),0)+isnull(sum(D1a7saldo),0)+isnull(sum(D8a15saldo),0)+isnull(sum(D16a30saldo),0) Vig0a30saldo  
,isnull(sum(D31a60saldo),0)+isnull(sum(D61a89saldo),0) Atr31a89saldo  
,isnull(sum(D90a120saldo),0)+isnull(sum(D121a150saldo),0)+isnull(sum(D151a180saldo),0)  
+isnull(sum(D181a210saldo),0)+isnull(sum(D211a240saldo),0)+isnull(sum(Dm241saldo),0) Ven90msaldo  
  
, isnull((sum(Dm31saldo)/sum(saldocapital))*100,0) Imor30  
, isnull((sum(Dm61saldo)/sum(saldocapital))*100,0) Imor60  
, isnull((sum(Dm90saldo)/sum(saldocapital))*100,0) Imor90  
  
,isnull(count(codprestamo),0) totalnro  
,isnull(count(D0nro),0) D0nro  
,isnull(count(D1a7nro),0) D1a7nro  
,isnull(count(D8a15nro),0) D8a15nro  
,isnull(count(D16a30nro),0) D16a30nro  
,isnull(count(D31a60nro),0) D31a60nro  
,isnull(count(D61a89nro),0) D61a89nro  
,isnull(count(D90a120nro),0) D90a120nro  
,isnull(count(D121a150nro),0) D121a150nro  
,isnull(count(D151a180nro),0) D151a180nro  
,isnull(count(D181a210nro),0) D181a210nro  
,isnull(count(D211a240nro),0) D211a240nro  
,isnull(count(Dm241nro),0) Dm241nro  
  
,isnull(count(D0nro),0)+isnull(count(D1a7nro),0)+isnull(count(D8a15nro),0)+isnull(count(D16a30nro),0) Vig0a30nro  
,isnull(count(D31a60nro),0)+isnull(count(D61a89nro),0) Atr31a89nro  
,isnull(count(D90a120nro),0)+isnull(count(D121a150nro),0)+isnull(count(D151a180nro),0)  
+isnull(count(D181a210nro),0)+isnull(count(D211a240nro),0)+isnull(count(Dm241nro),0) Ven90mnro  
,ciclo  
--into FNMGConsolidado.dbo.tCACubetasxSucCiclo  
from (  
  SELECT c.Fecha,c.codoficina  
  ,case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end saldocapital  
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso=0 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end  
   else 0 end D0saldo  
  
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7  
   then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end else 0 end D1a7saldo  
    
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15  
    then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end   
  else 0 end D8a15saldo  
  
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30  
    then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end  
   else 0 end D16a30saldo  
  
  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D31a60saldo  
  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D61a89saldo  
  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D90a120saldo  
 ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D121a150saldo  
 ,case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D151a180saldo  
 ,case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D181a210saldo  
 ,case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end D211a240saldo  
  ,case when c.NroDiasAtraso>=241 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end Dm241saldo  
  
 ,case when c.NroDiasAtraso>=31 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end Dm31saldo  
 ,case when c.NroDiasAtraso>=61 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end Dm61saldo  
 ,case when c.NroDiasAtraso>=90 then (case when c.codfondo<>20 then cd.saldocapital else cd.saldocapital*0.3 end) else 0 end Dm90saldo  
 -----------------------  
 ,c.codprestamo  
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso=0 then c.codprestamo else null end  
   else null end D0nro  
  
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7  
   then c.codprestamo else null end else null end D1a7nro  
    
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then c.codprestamo else null end   
  else null end D8a15nro  
  
  ,case when c.Estado<>'VENCIDO' then  
    case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then c.codprestamo else null end  
   else null end D16a30nro  
  
  ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then c.codprestamo else null end D31a60nro  
  ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then c.codprestamo else null end D61a89nro  
  ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then c.codprestamo else null end D90a120nro  
 ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then c.codprestamo else null end D121a150nro  
 ,case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then c.codprestamo else null end D151a180nro  
 ,case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then c.codprestamo else null end D181a210nro  
 ,case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then c.codprestamo else null end D211a240nro  
  ,case when c.NroDiasAtraso>=241 then c.codprestamo else null end Dm241nro  
  ,pd.secuenciacliente ciclo  
  FROM tCsCartera c with(nolock)  
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
  inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=c.codprestamo  
  where c.fecha=@fecha   
  and c.codprestamo in(select codprestamo from #ptmos)  
  and c.cartera='ACTIVA'  
 --and c.codoficina=304  
) a  
group by codoficina,ciclo    
  
--set @T2 = getdate()  
--print 'T3 '+ cast( datediff(millisecond, @T1, @T2) as varchar(30))  
--set @T1 = getdate()  
  
drop table #ptmos  
  
GO