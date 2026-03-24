SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsOpCaCubNacionalMov] 
as

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
select @fecini=dateadd(day,(-1)*day(@fecha),@fecha)

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo
from tcscartera with(nolock)
where fecha=@fecini 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)


select
@fecini fecha
,region
,count(distinct D0nroptmo) D0nroptmo
,sum(D0saldo) D0saldo
,count(distinct D1a7nroptmo) D1a7nroptmo
,sum(D1a7saldo) D1a7saldo
,count(distinct D8a15nroptmo) D8a15nroptmo
,sum(D8a15saldo) D8a15saldo
,count(distinct D16a30nroptmo) D16a30nroptmo
,sum(D16a30saldo) D16a30saldo
,count(distinct D31a60nroptmo) D31a60nroptmo
,sum(D31a60saldo) D31a60saldo
,count(distinct D61a89nroptmo) D61a89nroptmo
,sum(D61a89saldo) D61a89saldo
,count(distinct D90a240nroptmo) D90a240nroptmo
,sum(D90a240saldo) D90a240saldo
,count(distinct Dm241infnroptmo) Dm241infnroptmo
,sum(Dm241infsaldo) Dm241infsaldo
,count(distinct NroTotal) NroTotal
,sum(SaldTotal) SaldTotal
into #Cube1
from (

 SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo
 ,o.nomoficina
 ,z.nombre region
 ,cd.saldocapital

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.codprestamo else null end else null end D0nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end else 0 end D0saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end else null end D1a7nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end else 0 end D1a7saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end else null end D8a15nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end else 0 end D8a15saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end else null end D16a30nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end D16a30saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end else null end D31a60nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end else 0 end D31a60saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end else null end D61a89nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end else 0 end D61a89saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=240 then cd.codprestamo else null end else null end D90a240nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=240 then cd.saldocapital else 0 end else 0 end D90a240saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.codprestamo else null end else null end Dm241infnroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.saldocapital else 0 end else 0 end Dm241infsaldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 then cd.saldocapital else null end else null end NroTotal
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 then cd.saldocapital else 0 end else 0 end SaldTotal
 FROM tCsCartera c with(nolock)
 inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
 inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
 inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
 inner join tclzona z on z.zona=o.zona
 where c.fecha=@fecini
 and c.codprestamo in(select codprestamo from #ptmos)


) a
 group by region


--FINAL

truncate table #ptmos 
insert into #ptmos
select distinct codprestamo
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)


select
@fecha fecha
,region
,count(distinct D0nroptmo) D0nroptmo
,sum(D0saldo) D0saldo
,count(distinct D1a7nroptmo) D1a7nroptmo
,sum(D1a7saldo) D1a7saldo
,count(distinct D8a15nroptmo) D8a15nroptmo
,sum(D8a15saldo) D8a15saldo
,count(distinct D16a30nroptmo) D16a30nroptmo
,sum(D16a30saldo) D16a30saldo
,count(distinct D31a60nroptmo) D31a60nroptmo
,sum(D31a60saldo) D31a60saldo
,count(distinct D61a89nroptmo) D61a89nroptmo
,sum(D61a89saldo) D61a89saldo
,count(distinct D90a240nroptmo) D90a240nroptmo
,sum(D90a240saldo) D90a240saldo
,count(distinct Dm241infnroptmo) Dm241infnroptmo
,sum(Dm241infsaldo) Dm241infsaldo
,count(distinct NroTotal) NroTotal
,sum(SaldTotal) SaldTotal
into #cube2
from (

 SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo
 ,o.nomoficina
 ,z.nombre region
 ,cd.saldocapital

 /*   Total    */
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.codprestamo else null end else null end D0nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end else 0 end D0saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end else null end D1a7nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end else 0 end D1a7saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end else null end D8a15nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end else 0 end D8a15saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end else null end D16a30nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end D16a30saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end else null end D31a60nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end else 0 end D31a60saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end else null end D61a89nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end else 0 end D61a89saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=240 then cd.codprestamo else null end else null end D90a240nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=240 then cd.saldocapital else 0 end else 0 end D90a240saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.codprestamo else null end else null end Dm241infnroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.saldocapital else 0 end else 0 end Dm241infsaldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 then cd.saldocapital else null end else null end NroTotal
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 then cd.saldocapital else 0 end else 0 end SaldTotal
 FROM tCsCartera c with(nolock)
 inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
 inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
 inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
 inner join tclzona z on z.zona=o.zona
 where c.fecha=@fecha 
 and c.codprestamo in(select codprestamo from #ptmos)


) a
 group by region

select * From (
 select 1 orden,* from #cube1
union
select 2 orden,* from #cube2
union
select 3 orden,c1.fecha ,c2.region,c2.D0nroptmo-c1.D0nroptmo D0nrototal,c2.D0saldo-c1.D0saldo D0saldototal,c2.D1a7nroptmo-c1.D1a7nroptmo D1a7nrototal,c2.D1a7saldo-c1.D1a7saldo D1a7saldototal,c2.D8a15nroptmo-c1.D8a15nroptmo D8a15nrototal,c2.D8a15saldo-c1.D8a15saldo D8a15saldototal,
c2.D16a30nroptmo-c1.D16a30nroptmo D16a30nrototal,c2.D16a30saldo-c1.D16a30saldo D16a30saldototal,
c2.D31a60nroptmo-c1.D31a60nroptmo D31a60nrototal,c2.D31a60saldo-c1.D31a60saldo D31a60saldototal,
c2.D61a89nroptmo-c1.D61a89nroptmo D61a89nrototal,c2.D61a89saldo-c1.D61a89saldo D61a89saldototal,
c2.D90a240nroptmo-c1.D90a240nroptmo D90a240nrototal,c2.D90a240saldo-c1.D90a240saldo D90a240saldototal,
c2.Dm241infnroptmo-c1.Dm241infnroptmo Dm240infnrototal,c2.Dm241infsaldo-c1.Dm241infsaldo Dm241infsaldototal,
c2.NroTotal-c1.NroTotal NroTotalComp, c2.SaldTotal-c1.SaldTotal SaldTotalComp
from #cube2 c2
inner join #cube1 c1 on c1.region=c2.region
) a
where region <> 'Zona Cerradas' 

drop table #cube1
drop table #cube2
drop table #ptmos

GO