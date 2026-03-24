SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext [pCsOpCaCompMoraSuc] 'Z12'

CREATE procedure [dbo].[pCsOpCaCompMoraSuc] @zona varchar(5)
as
set nocount on--off

--declare @zona varchar(5)
--set @zona='Z12'

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
select @fecini=dateadd(day,(-1)*day(@fecha),@fecha)

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codoficina
from tcloficinas
where zona=@zona

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecini
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)--> son clientes que no son de Finamigo
and codoficina in(select codigo from @sucursales)

select 'inicial' tabla,@fecini fecha,sucursal
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo
,count(distinct D1a7nroptmo) D1a7nroptmo,sum(D1a7saldo) D1a7saldo
,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo
,count(distinct D16a20nroptmo) D16a20nroptmo,sum(D16a20saldo) D16a20saldo
,count(distinct D21a30nroptmo) D21a30nroptmo,sum(D21a30saldo) D21a30saldo
,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo
,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo
,count(distinct D90a120nroptmo) D90a120nroptmo,sum(D90a120saldo) D90a120saldo
,count(distinct D121a239nroptmo) D121a239nroptmo,sum(D121a239saldo) D121a239saldo
,count(distinct D240nroptmo) D240nroptmo,sum(D240saldo) D240saldo
,(sum(DM31saldo)/sum(saldocapital))*100 DM31imor
into #Cubeta
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal,cd.saldocapital
            ,case when c.NroDiasAtraso=0 then cd.codprestamo else null end D0nroptmo
            ,case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end D0saldo

            ,case when c.NroDiasAtraso>=1 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D1a7nroptmo
            ,case when c.NroDiasAtraso>=1 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D1a7saldo

            ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end D8a15nroptmo
            ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end D8a15saldo

            ,case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=20 then cd.codprestamo else null end D16a20nroptmo
            ,case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=20 then cd.saldocapital else 0 end D16a20saldo

            ,case when c.NroDiasAtraso>=21 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D21a30nroptmo
            ,case when c.NroDiasAtraso>=21 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D21a30saldo

            ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end D31a60nroptmo
            ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end D31a60saldo

            ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end D61a89nroptmo
            ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end D61a89saldo

            ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end D90a120nroptmo
            ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.saldocapital else 0 end D90a120saldo

            ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=239 then cd.codprestamo else null end D121a239nroptmo
            ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=239 then cd.saldocapital else 0 end D121a239saldo

            ,case when c.NroDiasAtraso>=240 then cd.codprestamo else null end D240nroptmo
            ,case when c.NroDiasAtraso>=240 then cd.saldocapital else 0 end D240saldo
            ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end DM31saldo
    
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
  where c.fecha=@fecini and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)     
) a
group by sucursal

/*Final*/
truncate table #ptmos
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)--> son clientes que no son de Finamigo
and codoficina in(select codigo from @sucursales)

select 'final' tabla,@fecha fecha,sucursal
,count(distinct codprestamo) nroptmo
,sum(saldocapital) saldocapital
,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo
,count(distinct D1a7nroptmo) D1a7nroptmo,sum(D1a7saldo) D1a7saldo
,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo
,count(distinct D16a20nroptmo) D16a20nroptmo,sum(D16a20saldo) D16a20saldo
,count(distinct D21a30nroptmo) D21a30nroptmo,sum(D21a30saldo) D21a30saldo
,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo
,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo
,count(distinct D90a120nroptmo) D90a120nroptmo,sum(D90a120saldo) D90a120saldo
,count(distinct D121a239nroptmo) D121a239nroptmo,sum(D121a239saldo) D121a239saldo
,count(distinct D240nroptmo) D240nroptmo,sum(D240saldo) D240saldo
,(sum(DM31saldo)/sum(saldocapital))*100 DM31imor
into #cubeta2
from (
  SELECT c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal,cd.saldocapital
            ,case when c.NroDiasAtraso=0 then cd.codprestamo else null end D0nroptmo
            ,case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end D0saldo

            ,case when c.NroDiasAtraso>=1 and c.NroDiasAtraso<=7 then cd.codprestamo else null end D1a7nroptmo
            ,case when c.NroDiasAtraso>=1 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end D1a7saldo

            ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end D8a15nroptmo
            ,case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end D8a15saldo

            ,case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=20 then cd.codprestamo else null end D16a20nroptmo
            ,case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=20 then cd.saldocapital else 0 end D16a20saldo

            ,case when c.NroDiasAtraso>=21 and c.NroDiasAtraso<=30 then cd.codprestamo else null end D21a30nroptmo
            ,case when c.NroDiasAtraso>=21 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end D21a30saldo

            ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end D31a60nroptmo
            ,case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end D31a60saldo

            ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end D61a89nroptmo
            ,case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end D61a89saldo

            ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end D90a120nroptmo
            ,case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.saldocapital else 0 end D90a120saldo

            ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=239 then cd.codprestamo else null end D121a239nroptmo
            ,case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=239 then cd.saldocapital else 0 end D121a239saldo

            ,case when c.NroDiasAtraso>=240 then cd.codprestamo else null end D240nroptmo
            ,case when c.NroDiasAtraso>=240 then cd.saldocapital else 0 end D240saldo
            ,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end DM31saldo
    
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codprestamo in(select codprestamo from #ptmos)     
) a
group by sucursal

select 'comparativo_mora' tabla,c2.sucursal,c2.D1a7nroptmo-c1.D1a7nroptmo + c2.D8a15nroptmo-c1.D8a15nroptmo+c2.D16a20nroptmo-c1.D16a20nroptmo+c2.D21a30nroptmo-c1.D21a30nroptmo D1a30creditos,
c2.D1a7saldo-c1.D1a7saldo+c2.D8a15saldo-c1.D8a15saldo+c2.D16a20saldo-c1.D16a20saldo+c2.D21a30saldo-c1.D21a30saldo D1a30saldos,
c2.D31a60nroptmo-c1.D31a60nroptmo+c2.D61a89nroptmo-c1.D61a89nroptmo D31a89creditos,
c2.D31a60saldo-c1.D31a60saldo+c2.D61a89saldo-c1.D61a89saldo D31a89saldos,
c2.D90a120nroptmo-c1.D90a120nroptmo + c2.D121a239nroptmo-c1.D121a239nroptmo + c2.D240nroptmo-c1.D240nroptmo D90creditos,
c2.D90a120saldo-c1.D90a120saldo + c2.D121a239saldo-c1.D121a239saldo + c2.D240saldo-c1.D240saldo D90saldos,
c2.D1a7nroptmo-c1.D1a7nroptmo + c2.D8a15nroptmo-c1.D8a15nroptmo+c2.D16a20nroptmo-c1.D16a20nroptmo+c2.D21a30nroptmo-c1.D21a30nroptmo + c2.D31a60nroptmo-c1.D31a60nroptmo+c2.D61a89nroptmo-c1.D61a89nroptmo + c2.D90a120nroptmo-c1.D90a120nroptmo + c2.D121a239nroptmo-c1.D121a239nroptmo + c2.D240nroptmo-c1.D240nroptmo Totalcreditos,
c2.D1a7saldo-c1.D1a7saldo+c2.D8a15saldo-c1.D8a15saldo+c2.D16a20saldo-c1.D16a20saldo+c2.D21a30saldo-c1.D21a30saldo + c2.D31a60saldo-c1.D31a60saldo+c2.D61a89saldo-c1.D61a89saldo + c2.D90a120saldo-c1.D90a120saldo + c2.D121a239saldo-c1.D121a239saldo + c2.D240saldo-c1.D240saldo Totalsaldos
from #cubeta2 c2
inner join #cubeta c1 on c1.sucursal=c2.sucursal



drop table #ptmos
drop table #cubeta
drop table #cubeta2
GO