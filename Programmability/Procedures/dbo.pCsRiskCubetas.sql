SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create procedure [dbo].[pCsRiskCubetas] 
as

--sp_helptext 
--exec [pCsRiskCubetas]

declare @hoy smalldatetime
select @hoy=fechaconsolidacion from vcsfechaconsolidacion
 

declare @fecha smalldatetime

set @fecha =(select primerdia from tclperiodo with(nolock) where primerdia<=@hoy and ultimodia>=@hoy)



declare @fecini smalldatetime

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

declare @fecfin smalldatetime

set @fecfin=@fecha

 
 CREATE TABLE #Mensual
(Fecha smalldatetime 
,D0saldo money
,D1a7saldo money
,D8a15saldo money
,D16a30saldo money
,D31a60saldo money
,D61a89saldo money
,D90a120saldo money 
,D121a150saldo money
,D151a180saldo money
,D181a210saldo money
,D211a240saldo money 
,Dm241infsaldo money 
,Castigadosaldo money
,capvigente30dm money 
,capvenc31dm money 
,capvigente90dm money
,capvenc90dm money) 

  while @fecha<=@hoy
 begin

create table #ptmos (codprestamo varchar(25))

insert into #ptmos

select distinct codprestamo 

from tcscartera with(nolock)

where fecha=@fecha 

and cartera='ACTIVA' and codoficina not in('97','230','231')

and codprestamo not in (select codprestamo from tCsCarteraAlta)

 

create table #ptmos2 (codprestamo varchar(25))

insert into #ptmos2

select codprestamo

from tcspadroncarteradet with(nolock)

where pasecastigado>=@fecini and pasecastigado<=@fecha

 

Insert into #Mensual

select 

@fecha fecha


,sum(D0saldo) D0saldo
,sum(D1a7saldo) D1a7saldo
,sum(D8a15saldo) D8a15saldo
,sum(D16a30saldo) D16a30saldo
,sum(D31a60saldo) D31a60saldo
,sum(D61a89saldo) D61a89saldo
,sum(D90a120saldo) D90a120saldo
,sum(D121a150saldo) D121a150saldo
,sum(D151a180saldo) D151a180saldo
,sum(D181a210saldo) D181a210saldo
,sum(D211a240saldo) D211a240saldo
,sum(Dm241infsaldo) Dm241infsaldo
,sum(Castigadosaldo) Castigadosaldo
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo) capvigente30dm
,sum(D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) capvenc31dm
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo) capvigente90dm
,sum(D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) capvenc90dm
--,(sum(D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo))/ (sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo))*100 imor30
--,(sum(D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo)) / (sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo))*100 imor90

 

from (

 

  SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo
  ,o.nomoficina
  ,z.nombre region

  ,cd.saldocapital

  --,c.CodAsesor

  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end promotor

  

  /*   Total    */

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.codprestamo else null end else null end D0nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end else 0 end D0saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end else null end D1a7nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end else 0 end D1a7saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end else null end D8a15nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end else 0 end D8a15saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end else null end  D16a30nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end D16a30saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end else null end  D31a60nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end else 0 end D31a60saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end else null end D61a89nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end else 0 end D61a89saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end else null end D90a120nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.saldocapital else 0 end else 0 end D90a120saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then cd.codprestamo else null end else null end D121a150nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then cd.saldocapital else 0 end else 0 end D121a150saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then cd.codprestamo else null end else null end D151a180nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then cd.saldocapital else 0 end else 0 end D151a180saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then cd.codprestamo else null end else null end D181a210nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then cd.saldocapital else 0 end else 0 end D181a210saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then cd.codprestamo else null end else null end D211a240nroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then cd.saldocapital else 0 end else 0 end D211a240saldo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.codprestamo else null end else null end Dm241infnroptmo

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.saldocapital else 0 end else 0 end Dm241infsaldo

,case when c.cartera='CASTIGADA' then cd.codprestamo else null end Castigadonroptmo

,case when c.cartera='CASTIGADA' then cd.saldocapital else 0 end Castigadosaldo

  FROM tCsCartera c with(nolock)

  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo

  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario

  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina

  inner join tclzona z on z.zona=o.zona

  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor

  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha

  where c.fecha=@fecha--and c.cartera='ACTIVA' 

  and c.codprestamo in(select codprestamo from #ptmos)

  

  union 

  

    SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo, o.nomoficina

    ,z.nombre region

  ,cd.saldocapital  

  --,c.CodAsesor

  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end promotor

  

,null D0nroptmo

,0 D0saldo

,null D1a7nroptmo

,0 D1a7saldo

,null D8a15nroptmo

,0 D8a15saldo

,null  D16a30nroptmo

,0 D16a30saldo

,null D31a60nroptmo

,0 D31a60saldo

,null D61a89nroptmo

,0 D61a89saldo

,null D90a120nroptmo

,0 D90a120saldo

,null D121a150nroptmo

,0 D121a150saldo

,null D151a180nroptmo

,0 D151a180saldo

,null D181a210nroptmo

,0 D181a210saldo

,null D211a240nroptmo

,0 D211a240saldo

,null Dm241infnroptmo

,0 Dm241infsaldo

,cd.CodPrestamo Castigadonroptmo

,cd.saldocapital Castigadosaldo

 

 

  FROM tCsCartera c with(nolock)

  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo

  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario

  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina

  inner join tclzona z on z.zona=o.zona

  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor

  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha

 

  where c.fecha=@fecha-2--and c.cartera='ACTIVA' 

  and c.codprestamo in(select codprestamo from #ptmos2)

  

) a
  

drop table #ptmos

drop table #ptmos2

set @fecha=dateadd(day,1,@fecha)

end


select * from #Mensual
drop table #Mensual
GO