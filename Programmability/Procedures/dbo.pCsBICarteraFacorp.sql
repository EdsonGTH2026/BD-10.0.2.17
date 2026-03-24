SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBICarteraFacorp] 
as

--sp_helptext 
--exec [pCsBICarteraFacorp]

declare @fecactual smalldatetime
select @fecactual = fechaconsolidacion from vcsfechaconsolidacion



declare @inicio smalldatetime
select @inicio = '20190101'

  CREATE TABLE #historico
  ( FECHA smalldatetime
  ,SUCURSAL varchar(100)
  ,TIPO varchar(20)
  ,REGION varchar (100)
  ,SALDOCAPITALFIN money
  ,SALDOCASTIGADO money
  ,CAPVIG30FIN money
  ,CAPVEN30FIN money
  ,CAPVIG90FIN money
  ,CAPVEN90FIN money
  ,SALDOCAPITALINI money
  ,CAPVIG30INI money
  ,CAPVEN30INI money
  ,CAPVIG90INI money
  ,CAPVEN90INI money
  ,CRECVIGENTE money
  ,CRECVENCIDA money) 

while (@inicio<=@fecactual)
begin 

declare @fecha smalldatetime
select @fecha =(select ultimodia from tclperiodo with(nolock) where primerdia<=@inicio and ultimodia>=@inicio)

IF @fecha >= @fecactual
 set @fecha = @fecactual
 
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

declare @mespasado smalldatetime
set @mespasado = dateadd(month,(-1),@fecha)

declare @feciniprim smalldatetime
set @feciniprim = (select primerdia from tclperiodo with(nolock) where @mespasado>=primerdia and @mespasado<=ultimodia)

declare @fecfinprim smalldatetime
set @fecfinprim = (select ultimodia from tclperiodo with(nolock) where @mespasado>=primerdia and @mespasado<=ultimodia)

declare @fecfin smalldatetime
set @fecfin=@fecha

create table #ptmosini (codprestamo varchar(25))
insert into #ptmosini
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecfinprim 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

create table #ptmosini2 (codprestamo varchar(25))
insert into #ptmosini2
select codprestamo
from tcspadroncarteradet with(nolock)
where pasecastigado>=@feciniprim and pasecastigado<=@fecfinprim

create table #ptmostotini
( fecha smalldatetime
 ,nomoficina varchar(200)
 ,region varchar(200)
 ,saldocapital money
 ,castigadosaldo money
 ,capvigente30dm money
 ,capvenc31dm money
 ,capvigente90dm money
 ,capvencido90dm money)
 
Insert into #ptmostotini

select 
@fecfinprim fecha
--,'total' cartera
,nomoficina --HABILITAR PARA OBTENERLO POR SUCURSAL--
,region --  HABILITAR PARA OBTENERLO POR REGION--
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) saldocapital
,sum(Castigadosaldo) Castigadosaldo
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo) capvigente30dm
,sum(D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) capvenc31dm
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo) capvigente90dm
,sum(D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) capvenc90dm

from (

  SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo
  ,o.nomoficina
  ,z.nombre region
  ,cd.saldocapital
  ,c.CodAsesor
  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end promotor
  

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.codprestamo else null end else null end D0nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end )  else 0 end else 0 end D0saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end else null end D1a7nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D1a7saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end else null end D8a15nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D8a15saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end else null end  D16a30nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D16a30saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end else null end  D31a60nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D31a60saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end else null end D61a89nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D61a89saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end else null end D90a120nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D90a120saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then cd.codprestamo else null end else null end D121a150nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end) else 0 end else 0 end D121a150saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then cd.codprestamo else null end else null end D151a180nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D151a180saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then cd.codprestamo else null end else null end D181a210nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D181a210saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then cd.codprestamo else null end else null end D211a240nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D211a240saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.codprestamo else null end else null end Dm241infnroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end Dm241infsaldo
,case when c.cartera='CASTIGADA' then cd.codprestamo else null end Castigadonroptmo
,case when c.cartera='CASTIGADA' then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end Castigadosaldo



  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tclzona z on z.zona=o.zona
  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecfinprim
  where c.fecha=@fecfinprim--and c.cartera='ACTIVA' 
  and c.codprestamo in(select codprestamo from #ptmosini)
  
  union 
  
    SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo, o.nomoficina
    ,z.nombre region
  ,cd.saldocapital  
  ,c.CodAsesor
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
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecfinprim

  where c.fecha=@fecfinprim--and c.cartera='ACTIVA' 
  and c.codprestamo in(select codprestamo from #ptmosini2)
  
) a
  group by region, nomoficina
 --,promotor
 --codprestamo
 --,secuenciacliente


create table #ptmosfin (codprestamo varchar(25))
insert into #ptmosfin
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha 
and cartera='ACTIVA' and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

create table #ptmosfin2 (codprestamo varchar(25))
insert into #ptmosfin2
select codprestamo
from tcspadroncarteradet with(nolock)
where pasecastigado>=@fecini and pasecastigado<=@fecha

create table #ptmostotfin
( fecha smalldatetime
 ,nomoficina varchar(200)
 ,tipo varchar(20)
 ,region varchar(200)
 ,saldocapital money
 ,castigadosaldo money
 ,capvigente30dm money
 ,capvenc31dm money
 ,capvigente90dm money
 ,capvencido90dm money)
 
Insert into #ptmostotfin

select 
@fecha fecha
--,'total' cartera
,nomoficina --HABILITAR PARA OBTENERLO POR SUCURSAL--
,tipo
,region --  HABILITAR PARA OBTENERLO POR REGION--
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) saldocapital
,sum(Castigadosaldo) Castigadosaldo
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo) capvigente30dm
,sum(D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) capvenc31dm
,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo) capvigente90dm
,sum(D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) capvenc90dm

from (

  SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo
  ,o.nomoficina
  ,case when o.esvirtual = 1 then 'Virtual' else 'Fisica' end Tipo
  ,z.nombre region
  ,cd.saldocapital
  ,c.CodAsesor
  ,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end promotor
  

,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.codprestamo else null end else null end D0nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end )  else 0 end else 0 end D0saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end else null end D1a7nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D1a7saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end else null end D8a15nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D8a15saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end else null end  D16a30nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D16a30saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end else null end  D31a60nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D31a60saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end else null end D61a89nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D61a89saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end else null end D90a120nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D90a120saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then cd.codprestamo else null end else null end D121a150nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end) else 0 end else 0 end D121a150saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then cd.codprestamo else null end else null end D151a180nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D151a180saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then cd.codprestamo else null end else null end D181a210nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D181a210saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then cd.codprestamo else null end else null end D211a240nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end D211a240saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.codprestamo else null end else null end Dm241infnroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end else 0 end Dm241infsaldo
,case when c.cartera='CASTIGADA' then cd.codprestamo else null end Castigadonroptmo
,case when c.cartera='CASTIGADA' then (case when c.codfondo=21 then cd.saldocapital*0.75 else 0 end)  else 0 end Castigadosaldo



  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
  inner join tclzona z on z.zona=o.zona
  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha
  where c.fecha=@fecha--and c.cartera='ACTIVA' 
  and c.codprestamo in(select codprestamo from #ptmosfin)
  
  union 
  
    SELECT pd.secuenciacliente,c.Fecha,cd.codusuario,c.CodPrestamo, o.nomoficina
    ,case when o.esvirtual = 1 then 'Virtual' else 'Fisica' end Tipo
    ,z.nombre region
  ,cd.saldocapital  
  ,c.CodAsesor
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

  where c.fecha=@fecha--and c.cartera='ACTIVA' 
  and c.codprestamo in(select codprestamo from #ptmosfin2)
  
) a
  group by region, nomoficina, tipo


  
  INSERT INTO #historico
  select tf.fecha FECHA,tf.nomoficina SUCURSAL,tf.tipo TIPO,tf.region REGION,tf.saldocapital SALDOCAPITALFIN, tf.castigadosaldo SALDOCASTIGADO
  ,tf.capvigente30dm CAPVIG30FIN,tf.capvenc31dm CAPVEN30FIN,tf.capvigente90dm CAPVIG90FIN,tf.capvencido90dm CAPVEN90FIN
  ,ISNULL(ti.saldocapital,0) SALDOCAPITALINI, ISNULL(ti.capvigente30dm,0) CAPVIG30INI, ISNULL(ti.capvenc31dm,0) CAPVEN30INI
  , ISNULL(ti.capvigente90dm,0) CAPVIG90INI, ISNULL(ti.capvencido90dm,0) CAPVEN90INI
  , (tf.capvigente30dm-ISNULL(ti.capvigente30dm,0)) CRECVIGENTE
  , (tf.capvenc31dm-ISNULL(ti.capvenc31dm,0)+tf.castigadosaldo) CRECVENCIDA
  
  from #ptmostotfin tf with(nolock)
  left outer join #ptmostotini ti with(nolock) on ti.nomoficina=tf.nomoficina 
 

 
drop table #ptmosfin
drop table #ptmosfin2
drop table #ptmostotfin

drop table #ptmosini
drop table #ptmosini2
drop table #ptmostotini


	set @inicio=dateadd(month,1,@inicio)
	
	end




select * from #historico

drop table #historico
GO