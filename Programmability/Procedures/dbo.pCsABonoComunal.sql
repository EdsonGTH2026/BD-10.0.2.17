SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pCsABonoComunal      
--DROP PROC pCsABonoComunal          
--EXEC pCsABonoComunal '20140409',''          
CREATE PROCEDURE [dbo].[pCsABonoComunal]         
               ( @fecha      SMALLDATETIME ,          
                 @codoficina VARCHAR(300)  )          
AS      
/*
declare @fecha SMALLDATETIME          
    set @fecha = '20140331'          
*/          
DECLARE @fec_1ra SMALLDATETIME
DECLARE @fec_2da SMALLDATETIME
DECLARE @fec_3ra SMALLDATETIME
DECLARE @fec_4ta SMALLDATETIME
DECLARE @Periodo1 VARCHAR(6)
DECLARE @Periodo2 VARCHAR(6)
DECLARE @Periodo3 VARCHAR(6)
DECLARE @FechaIni1 SMALLDATETIME
DECLARE @FechaIni2 SMALLDATETIME
DECLARE @MesAñoAnt CHAR(6)

SET @fec_1ra   = @fecha
SET @Periodo1  = dbo.fduFechaATexto(@fec_1ra, 'AAAAMM')
SET @FechaIni1 = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))
SET @fec_2da   = DateAdd(d,-1,@FechaIni1)

SET @Periodo2  = dbo.fduFechaATexto(@fec_2da, 'AAAAMM')
SET @FechaIni2 = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo2 + '01' As SmallDateTime)))
SET @fec_3ra   = DateAdd(d,-1,@FechaIni2)

set @fec_4ta = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo3 + '01' As SmallDateTime)))

SET @MesAñoAnt = CONVERT(CHAR(4),YEAR(@FechaIni2))+CONVERT(CHAR(2),(CASE WHEN LEN(MONTH(@FechaIni2))= 1 THEN '0'+CONVERT(CHAR(1),MONTH(@FechaIni2)) ELSE CONVERT(CHAR(2),MONTH(@FechaIni2)) END))

--sp_helptext pCsAComerAhorroDiaATraso
/*
declare @fec_1ra smalldatetime
declare @fec_2da smalldatetime
declare @fec_3ra smalldatetime
declare @fec_4ta smalldatetime
set @fec_1ra='20140219'
set @fec_2da='20140131'
set @fec_3ra='20131231'--'20131031'
*/          

DECLARE @periodo_1ra VARCHAR(6)
DECLARE @periodo_2da VARCHAR(6)          
DECLARE @periodo_3ra VARCHAR(6)
declare @periodo_4ta varchar(6)
SET @periodo_1ra=dbo.fdufechaaperiodo(@fec_1ra)
SET @periodo_2da=dbo.fdufechaaperiodo(@fec_2da)
SET @periodo_3ra=dbo.fdufechaaperiodo(@fec_3ra)
set @periodo_4ta=dbo.fdufechaaperiodo(@fec_4ta)

CREATE TABLE #tmpca(
        codoficina   VARCHAR(4),
        nomoficina   VARCHAR(250),
        codasesor    VARCHAR(15),
        nomasesor    VARCHAR(250),
        duplicado    INT DEFAULT(0),
        ncliante     INT DEFAULT(0),
        ncliactu     INT DEFAULT(0),
        skantes      DECIMAL(16,4),
        skactual     DECIMAL(16,4),
        scantes      DECIMAL(16,4),
        scactual     DECIMAL(16,4),
        sc1antes     DECIMAL(16,4),
        sc1actual    DECIMAL(16,4),
        nnewcliante  INT DEFAULT(0),
        nnewcliactu  INT DEFAULT(0),
        snantes      DECIMAL(16,4),
        snactual     DECIMAL(16,4),
        s60antes     DECIMAL(16,4),
        s60actual    DECIMAL(16,4),
        n60antes     INT DEFAULT(0),
        n60actual    INT DEFAULT(0),
        moraantes    DECIMAL(16,2),
        moraactual   DECIMAL(16,2),
        nasignado    INT DEFAULT(0),
        sasignado    DECIMAL(16,4) DEFAULT(0),
        nrenovado    INT DEFAULT(0),
        nrenovadoU   INT DEFAULT(0),
        srenovado    DECIMAL(16,4) DEFAULT(0),
        squitado     DECIMAL(16,4) DEFAULT(0),
        nquitado     INT DEFAULT(0),
        sq0          DECIMAL(16,4) DEFAULT(0),
        sqm0         DECIMAL(16,4) DEFAULT(0),
        sqm90        DECIMAL(16,4) DEFAULT(0),
        sjuridico    DECIMAL(16,4) DEFAULT(0),
        nliquidado   INT DEFAULT(0),
        sliquidado   DECIMAL(16,4) DEFAULT(0),

        porrenovar   INT DEFAULT(0),
        nreasignado  INT DEFAULT(0),
        sreasignado  DECIMAL(16,4) DEFAULT(0),
        sreasignadom0 decimal(16,4) default(0),
        
        ANT1SC int default(0),
        ANT1SCm0 int default(0),  
        ANT2SC int default(0),
        ANT2SCm0 int default(0)

) 
                
--verificar que sea el primer asesor el que coloco?????          
INSERT INTO #tmpca (codoficina, nomoficina, codasesor, nomasesor, skantes, skactual, snantes, snactual, s60antes, s60actual          
                  , sc1antes, sc1actual,scantes,scactual,ncliante,ncliactu,nnewcliante,nnewcliactu,n60antes,n60actual)      
SELECT o.codoficina, o.nomoficina, c.codasesor,a.nomasesor--c.fecha,           
       ,sum(case when c.fecha=@fec_2da then (case when c.nrodiasatraso<61 then cd.saldocapital else 0 end) else 0 end) skantes          
       ,sum(case when c.fecha=@fec_1ra then (case when c.nrodiasatraso<61 then cd.saldocapital else 0 end) else 0 end) skactual          
       ,sum(case when c.fecha=@fec_2da then(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@periodo_2da and p.tiporeprog='SINRE' then cd.montodesembolso else 0 end)else 0 end) snantes          
       ,sum(case when c.fecha=@fec_1ra then(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@periodo_1ra and p.tiporeprog='SINRE' then cd.montodesembolso else 0 end)else 0 end) snactual          
       ,sum(case when c.fecha=@fec_2da then(case when c.nrodiasatraso>=61  and c.nrodiasatraso<=180 then cd.saldocapital else 0 end)else 0 end) s60antes          
       ,sum(case when c.fecha=@fec_1ra then(case when c.nrodiasatraso>=61  and c.nrodiasatraso<=180 then cd.saldocapital else 0 end)else 0 end) s60actual      
       ,sum(case when c.fecha=@fec_2da then(case when c.nrodiasatraso>0 and c.nrodiasatraso<61          
                 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)else 0 end) s1antes          
       ,sum(case when c.fecha=@fec_1ra then(case when c.nrodiasatraso>0 and c.nrodiasatraso<61           
                 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)else 0 end) s1actual          
       ,sum(case when c.fecha=@fec_2da then (case when c.nrodiasatraso<61          
                 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido  else 0 end) else 0 end) scantes          
       ,sum(case when c.fecha=@fec_1ra then (case when c.nrodiasatraso<61           
                 then cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) else 0 end) scactual          
       ,count(distinct(case when c.fecha=@fec_2da then (case when c.nrodiasatraso<61           
                            then cd.codusuario else null end) else null end)) ncliante --renovacion anterior y cartera asignada anterior          
       ,count(distinct(case when c.fecha=@fec_1ra then (case when c.nrodiasatraso<61           
                            then cd.codusuario else null end) else null end)) ncliactu          
       ,count(distinct(case when c.fecha=@fec_2da then(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@periodo_2da and p.tiporeprog='SINRE' then cd.codusuario else null end)else null end)) nnewcliante          
       ,count(distinct(case when c.fecha=@fec_1ra then(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@periodo_1ra and p.tiporeprog='SINRE' then cd.codusuario else null end)else null end)) nnewcliactu          
       ,count(distinct(case when c.fecha=@fec_2da then(case when c.nrodiasatraso>=61  and c.nrodiasatraso<=180 then cd.codusuario else null end)else null end)) n60antes          
       ,count(distinct(case when c.fecha=@fec_1ra then(case when c.nrodiasatraso>=61  and c.nrodiasatraso<=180 then cd.codusuario else null end)else null end)) n60actual      
  FROM tCsCartera c with(nolock)          
 INNER JOIN tcscarteradet      cd with(nolock) ON c.fecha = cd.fecha AND c.codprestamo = cd.codprestamo          
 INNER JOIN tcspadroncarteradet p with(nolock) ON p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario          
 INNER JOIN (SELECT codasesor, nomasesor FROM tCsPadronAsesores with(nolock) --where activo=1 and activoactual=1          
             ) a ON a.codasesor=c.codasesor          
 INNER JOIN tcloficinas o with(nolock) ON o.codoficina=c.codoficina          
 WHERE c.fecha in (@fec_2da,@fec_1ra)          
   AND c.cartera     = 'ACTIVA'          
   AND c.codproducto = '164'
   AND c.codasesor NOT IN (SELECT codusuario FROM tCsEmpleados WHERE codpuesto in(26,15,50)) --aqui quita a juridico          
 GROUP BY o.codoficina, o.nomoficina, c.codasesor, a.nomasesor          
 ORDER BY o.codoficina          
          
--REASIGNACION : CARTERA ASIGNADA - PERIODO ACTUAL          
--select fecha, codasesor, asignado           
UPDATE #tmpca
SET sasignado=asignado-renovacion,srenovado=renovacion      
,nrenovado=nrenova
,nrenovadoU=nrenovaU
,nasignado=a.nasignado-nrenova
,nreasignado = a.nreasignado
,sreasignado = a.sreasignado
,sreasignadom0 = a.sreasignadom0
FROM (Select ac.fecha,ac.codasesor,sum(ac.saldocapital) asignado
      ,sum(ac.nasignado) + sum(ac.nrenovaU) nasignado --sum(ac.nasignado)
      ,sum(ac.renovacion) renovacion
      ,sum(ac.nrenova) nrenova
      ,sum(ac.nrenovaU) nrenovaU
      ,sum(ac.nasignado) nreasignado --sum(ac.nasignado)-sum(ac.nrenova)
      ,sum(ac.sreasignado) sreasignado
      ,sum(ac.sreasignadom0) sreasignadom0
      From(
          select c.fecha, c.codprestamo, c.codasesor      
          ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_1ra or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_1ra and p.primerasesor<>c.codasesor) then cd.codusuario else null end)) nasignado      
          ,sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocapital      
          ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_1ra and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) renovacion      
          ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_1ra and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.codprestamo else null end)) nrenova      
          ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_1ra and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.codusuario else null end)) nrenovaU      
          ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_1ra or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_2da and p.primerasesor<>c.codasesor)
                then
                  (case when c.nrodiasatraso<61 then 
                    cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
                   else 0 end)
                else 0 end) sreasignado
          ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_1ra or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_2da and p.primerasesor<>c.codasesor)
              then (case when c.nrodiasatraso>0 and c.nrodiasatraso<61 then 
                    cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
                  else 0 end)
              else 0 end) sreasignadom0          
          from tCsCartera c with(nolock)      
          inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo      
          inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario      
          where c.fecha       = @fec_1ra      
                  and c.cartera       = 'ACTIVA'
                  and c.codproducto   = '164'      
                  and c.nrodiasatraso < 61      
          group by c.fecha, c.codprestamo, c.codasesor      
          ) ac      
          Left Outer Join
              (select c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital) saldocapital      
                 from tCsCartera c with(nolock)      
                inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo      
                where c.fecha=@fec_2da      
                  and c.cartera='ACTIVA'   
                  and c.codproducto = '164'   
                group by c.fecha, c.codprestamo, c.codasesor      
               ) an  ON ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor      
    Where an.fecha is null      
    Group By ac.fecha,ac.codasesor      
) a          
INNER JOIN #tmpca t on t.codasesor=a.codasesor          
          
--REASIGNACION : CARTERA ASIGNADA - PERIODO ANTERIOR
update #tmpca
set ANT1SC=a.saldocartera,ANT1SCm0=a.saldocarteram0
from (
  select f.codasesor,sum(sc.saldocartera) saldocartera, sum(sc.saldocarteram0) saldocarteram0
  from (
  select ac.fecha,ac.codasesor
  ,ac.codprestamo
  ,ac.nreasignado 
  ,ac.sreasignado
  ,ac.sreasignadom0
  from(
    SELECT c.fecha, c.codprestamo, c.codasesor
    ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_2da or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_2da and p.primerasesor<>c.codasesor) then cd.codprestamo else null end)) nreasignado  --codusuario
    ,sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocapital
    ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_2da and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) renovacion
    ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_2da and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.codprestamo else null end)) nrenova
    ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_2da or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_3ra and p.primerasesor<>c.codasesor)
          then 
             (case when c.nrodiasatraso<61 then 
              cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
              else 0 end)
          else 0 end) sreasignado
    ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_2da or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_3ra and p.primerasesor<>c.codasesor)
          then (case when c.nrodiasatraso>0 and c.nrodiasatraso<61 then 
                      cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
                    else 0 end)
          else 0 end) sreasignadom0
    FROM tCsCartera c with(nolock)
    inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
    inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
    where c.fecha=@fec_2da
    and c.cartera='ACTIVA'
    and c.codproducto='164'
    --and c.codasesor='CPO1107901'
    and c.nrodiasatraso<61
    group by c.fecha, c.codprestamo, c.codasesor
  ) ac
  left outer join (
    SELECT c.fecha, c.codprestamo, c.codasesor--, sum(cd.saldocapital) saldocapital
    FROM tCsCartera c with(nolock)
    inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
    where c.fecha=@fec_3ra
    and c.cartera='ACTIVA'
    and c.codproducto='164'
    --and c.codasesor='CPO1107901'
    group by c.fecha, c.codprestamo, c.codasesor
  ) an
  on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor
  where an.fecha is null and ac.nreasignado>0
  ) f
  inner join (
    select ca.codprestamo
    ,sum(case when nrodiasatraso<61 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido 
          else 0 end) saldocartera
    ,sum(case when nrodiasatraso>0 and nrodiasatraso<61 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido 
          else 0 end) saldocarteram0
    from tcscartera ca with(nolock) inner join tcscarteradet cd with(nolock) on ca.fecha=cd.fecha and ca.codprestamo=cd.codprestamo
    where ca.fecha=@fec_1ra
    group by ca.codprestamo
  ) sc
  on sc.codprestamo=f.codprestamo
  group by f.codasesor
) a
inner join #tmpca t on t.codasesor=a.codasesor

--REASIGNACION : CARTERA ASIGNADA - PERIODO ANTERIOR 2 --> 60 días
update #tmpca
set ANT2SC=a.saldocartera,ANT2SCm0=a.saldocarteram0
from (
  select f.codasesor,sum(sc.saldocartera) saldocartera, sum(sc.saldocarteram0) saldocarteram0
  from (
  select ac.fecha,ac.codasesor
  ,ac.codprestamo
  ,ac.nreasignado 
  ,ac.sreasignado
  ,ac.sreasignadom0
  from(
    SELECT c.fecha, c.codprestamo, c.codasesor
    ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_3ra or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_3ra and p.primerasesor<>c.codasesor) then cd.codprestamo else null end)) nreasignado  --codusuario
    ,sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocapital
    ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_3ra and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) renovacion
    ,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_3ra and p.secuenciacliente<>1 and p.primerasesor=c.codasesor then cd.codprestamo else null end)) nrenova
    ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_3ra or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_4ta and p.primerasesor<>c.codasesor)
          then 
              (case when c.nrodiasatraso<61 then 
              cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
              else 0 end)
          else 0 end) sreasignado
    ,sum(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>@periodo_3ra or (dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo_4ta and p.primerasesor<>c.codasesor)
          then (case when c.nrodiasatraso>0 and c.nrodiasatraso<61 then 
                      cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
                    else 0 end)
          else 0 end) sreasignadom0
    FROM tCsCartera c with(nolock)
    inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
    inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
    where c.fecha=@fec_3ra
    and c.cartera='ACTIVA'
    and c.codproducto='164'
    --and c.codasesor='CPO1107901'
    and c.nrodiasatraso<61
    group by c.fecha, c.codprestamo, c.codasesor
  ) ac
  left outer join (
    SELECT c.fecha, c.codprestamo, c.codasesor--, sum(cd.saldocapital) saldocapital
    FROM tCsCartera c with(nolock)
    inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
    where c.fecha=@fec_4ta
    and c.cartera='ACTIVA'
    and c.codproducto='164'
    --and c.codasesor='CPO1107901'
    group by c.fecha, c.codprestamo, c.codasesor
  ) an
  on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor
  where an.fecha is null and ac.nreasignado>0
  ) f
  inner join (
    select ca.codprestamo
    ,sum(case when nrodiasatraso<61 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido 
          else 0 end) saldocartera
    ,sum(case when nrodiasatraso>0 and nrodiasatraso<61 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido 
          else 0 end) saldocarteram0
    from tcscartera ca with(nolock) inner join tcscarteradet cd with(nolock) on ca.fecha=cd.fecha and ca.codprestamo=cd.codprestamo
    where ca.fecha=@fec_1ra
    group by ca.codprestamo
  ) sc
  on sc.codprestamo=f.codprestamo
  group by f.codasesor
) a
inner join #tmpca t on t.codasesor=a.codasesor

          
--REASIGNACION : CARTERA QUITADA          
UPDATE #tmpca          
   SET squitado=quitado-liquidacion-juridico,sjuridico=juridico,sq0=q0,sqm0=qm0,sqm90=qm90          
       ,sliquidado=liquidacion,nliquidado=nliquidacion,nquitado=a.nquitado      
  FROM (Select an.fecha,an.codasesor,sum(an.saldocapital) quitado--an.saldocapital--an.codprestamo          
               ,sum(case when j.codusuario is not null then an.saldocapital else 0 end) juridico          
               ,sum(case when dbo.fdufechaaperiodo(p.cancelacion)=@periodo_1ra then an.nroclientes else 0 end) nliquidacion      
               ,sum(case when p.cancelacion is null then an.nroclientes else 0 end) nquitado      
               ,sum(case when dbo.fdufechaaperiodo(p.cancelacion)=@periodo_1ra then an.saldocapital else 0 end) liquidacion          
               ,sum(case when p.cancelacion is null then --an.q0           
                    case when j.codusuario is not null then 0 else an.q0 end          
                         else 0 end) q0          
               ,sum(case when p.cancelacion is null then (          
                    case when j.codusuario is not null then 0 else an.qm0 end          
                   ) else 0 end) qm0          
               ,sum(case when p.cancelacion is null then (          
                    case when j.codusuario is not null then 0 else an.qm90 end          
                   ) else 0 end) qm90          
          From(select c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital) saldocapital          
                 from tCsCartera c with(nolock)          
                inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo          
                inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario          
                where c.fecha=@fec_1ra      
                  and c.cartera='ACTIVA'   
                  and c.codproducto = '164'       
                group by c.fecha, c.codprestamo, c.codasesor          
               ) ac          
                right outer join 
               (select c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocapital          
                       ,sum(case when c.nrodiasatraso=0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) q0          
                       ,sum(case when c.nrodiasatraso>0 and c.nrodiasatraso<91 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) qm0          
                       ,sum(case when c.nrodiasatraso>90 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) qm90--aqui creo poner:c.nrodiasatraso<91          
                       ,count(distinct cd.codusuario) nroclientes      
                  from tCsCartera c with(nolock)
                 inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo          
                 where c.fecha       = @fec_2da          
                   and c.cartera     = 'ACTIVA'   
                   and c.codproducto = '164'       
                 group by c.fecha, c.codprestamo, c.codasesor          
               ) an on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor          
           left outer join tcscartera cx with(nolock) on cx.codprestamo=an.codprestamo and cx.fecha=@fec_1ra          
           left outer join (select codusuario from tCsEmpleados where codpuesto in(26,15,50)) j on cx.codasesor=j.codusuario          
           left outer join (--liquidado          
                            select distinct codprestamo, cancelacion from tcspadroncarteradet with(nolock)          
                             where estadocalculado='CANCELADO' and codproducto = '164' and dbo.fdufechaaperiodo(cancelacion)=@periodo_1ra          
                           ) p on p.codprestamo=an.codprestamo          
        where ac.fecha is null          
        group by an.fecha,an.codasesor          
     ) a          
inner join #tmpca t on t.codasesor=a.codasesor          
          
/*CLIENTES POR RENOVAR EN EL MES*/          
UPDATE #tmpca          
   SET porrenovar=a.porrenovar          
  FROM (Select p.últimoasesor codasesor,count(p.codprestamo) porrenovar    --codusuario      
          From tcspadroncarteradet p with(nolock)          
         Inner Join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha          
         Where dbo.fdufechaaperiodo(c.fechavencimiento)=@MesAñoAnt--'201401' --fechavencimiento>='20140101' and fechavencimiento<='20140131'          
           And p.estadocalculado<>'CASTIGADA'
           And c.codproducto = '164'          
           And c.nrodiasatraso<61          
           And (p.cancelacion is null or dbo.fdufechaaperiodo(p.cancelacion)=@MesAñoAnt)--'201401')          
         Group By p.últimoasesor          
       ) a          
INNER JOIN #tmpca t ON t.codasesor=a.codasesor          
          
--UPDATE #tmpca          
--   SET moraantes=(sc1antes/(case when scantes=0 then 1 else scantes end))*100          
--       ,moraactual=          
--       case when isnull(scactual,0)+isnull(sqm0,0)+isnull(sq0,0) = 0 then 0          
--            else ((isnull(sc1actual,0)+isnull(sqm0,0)) / (isnull(scactual,0)+isnull(sq0,0)+isnull(sqm0,0)))*100          
--            end
update #tmpca
set moraantes=(sc1antes/(case when scantes=0 then 1 else scantes end))*100
,moraactual=
case when isnull(scactual,0)+isnull(sqm0,0)+isnull(sq0,0)-isnull(sreasignado,0)-isnull(ANT1SCm0,0)-isnull(ANT2SCm0,0)= 0 then 0
else
    case when (isnull(scactual,0)+isnull(sq0,0)+isnull(sqm0,0))=0 then 0
    else--ANT1SC,ANT1SCm0,ANT2SC,ANT2SCm0
      ((isnull(sc1actual,0)+isnull(sqm0,0)-isnull(sreasignadom0,0)-isnull(ANT1SCm0,0)-isnull(ANT2SCm0,0)) / 
      (isnull(scactual,0)+isnull(sq0,0)+isnull(sqm0,0)-isnull(sreasignado,0)-isnull(ANT1SCm0,0)-isnull(ANT2SCm0,0)))*100
    end
end
          
UPDATE #tmpca          
  SET duplicado=nro          
 FROM (Select nomasesor,count(nomasesor) nro          
         From #tmpca          
        Group by nomasesor          
       Having count(nomasesor)>1          
      ) a          
INNER JOIN #tmpca b ON a.nomasesor = b.nomasesor          
          
CREATE TABLE #tmpca2
     ( codoficina  VARCHAR(4),          
       nomoficina  VARCHAR(250),          
       codasesor   VARCHAR(15),          
       nomasesor   VARCHAR(250),          
       duplicado   INT DEFAULT(0),          
       cliAnt      INT DEFAULT(0),--decimal(16,4),          
       nnewcliactu INT DEFAULT(0),          
       nliquidado  INT DEFAULT(0),          
       ClientesTotales NUMERIC(16),           
       CrecimientoCtes NUMERIC(16),           
       nrenovado   INT DEFAULT(0),      
       nrenovadoU  INT DEFAULT(0),      
       clientesArenovarenmes INT DEFAULT(0),          
       porrenovar  INT DEFAULT(0),          
       skantes     DECIMAL(16,4),          
       skactual    DECIMAL(16,4),          
       CrecimientoCartera DECIMAL(16,4),          
       moraactual  DECIMAL(16,2),      
       nreasignado INT DEFAULT(0),      
       sreasignado DECIMAL(16,2),     
	sreasignadom0 decimal(16,2), 
       ncliante    INT DEFAULT(0),      
       ncliactu    INT DEFAULT(0),      
       nquitado    INT DEFAULT(0),      
       n60antes    INT DEFAULT(0),      
       n60actual   INT DEFAULT(0) ,
      s60antes decimal(16,4),
      s60actual decimal(16,4),
      
      ANT1SC int default(0),
      ANT1SCm0 int default(0),
      ANT2SC int default(0),
      ANT2SCm0 int default(0)
)
          
INSERT INTO #tmpca2          
SELECT p.codoficina, p.nomoficina, p.codasesor, p.nomasesor, p.duplicado,          
       ncliante As CliAnt,      
       p.nnewcliactu,          
       p.nliquidado,           
       ncliante + p.nnewcliactu - p.nliquidado ClientesTotales,      
      (p.nnewcliactu - p.nliquidado) CrecimientoCtes,          
       p.nrenovado,p.nrenovadoU, isnull(p.porrenovar,0) clientesArenovarenmes,   --isnull(r.ValorProg,0) clientesArenovarenmes,   --   
       case when isnull(p.porrenovar,0) = 0 --p.porrenovar=0           
            then case when p.nrenovado > 0           
                      then 100          
                      else 0           
                      end          
            else           
                 case when cast((cast(p.nrenovado as decimal(10,2))/cast(isnull(p.porrenovar,0) as decimal(10,2)))*100 as decimal(10,2)) > 100 --cast((cast(p.nrenovado as decimal(10,2))/cast(p.porrenovar as decimal(10,2)))*100 as decimal(10,2)) > 100       
                      then 100          
                      else cast((cast(p.nrenovado as decimal(10,2))/cast(isnull(p.porrenovar,0) as decimal(10,2)))*100 as decimal(10,2))       --cast((cast(p.nrenovado as decimal(10,2))/cast(p.porrenovar as decimal(10,2)))*100 as decimal(10,2))           
                      end          
            end           
       porrenova          
       ,p.scantes skantes, p.scactual skactual, (p.scactual-sreasignado) - (p.scantes-ANT1SC) CrecimientoCartera          
       ,p.moraactual          
       ,p.nreasignado, p.sreasignado      , p.sreasignadom0
       ,ncliante      
       ,ncliactu,nquitado      
       ,n60antes,n60actual      
	,s60antes,s60actual
	,ANT1SC,ANT1SCm0,ANT2SC,ANT2SCm0
FROM #tmpca p          
ORDER BY p.codasesor          
          
IF  EXISTS (SELECT * FROM tCsRptBonoComunal) --dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptBonoCartera]'))-- AND type = 'D')          
BEGIN
    DROP TABLE tCsRptBonoComunal
END

SELECT @fec_1ra as fecha,           
       b.codoficina,b.nomoficina,z.nombre region,b.codasesor,b.nomasesor,       
       e.Ingreso FechaIngreso,       
       dbo.fCsAntiguedad(e.Ingreso,getdate()) Antiguedad, 
       --cast(datediff(month,e.Ingreso,getdate()) as varchar(6)) Antiguedad,     
       e.CodEmpleado NumEmpleado, pu.Descripcion puesto,case when e.estado=1 then 'ACTIVO' else 'BAJA' end EstadoAsesor,b.duplicado      
       ,ncliactu      
       ,n60actual      
       ,nquitado      
       ,case when b.cliAnt < 0 then 0 else b.cliAnt end CtesMesAnt      
       , b.nnewcliactu CtesNvos, b.nliquidado,       
       case when b.ClientesTotales < 0 then 0 else b.ClientesTotales end ClientesTotales, b.CrecimientoCtes,       
       b.nreasignado, b.sreasignado,      b.sreasignadom0,
       b.nrenovado RenovacionxPrestamo,b.nrenovadoU RenovacionxCliente ,b.clientesArenovarenmes,          
       b.porrenovar,       
       b.skantes SaldoMesAnt, b.skactual SaldoMesAct, b.CrecimientoCartera, b.moraactual,          
       isnull(f1.VarBono ,0) BonoxCrecimientoCtes,  isnull(f2.VarBono ,0)* b.nrenovado BonoxRenovacion,          
       isnull(f3.VarBono ,0) BonoxCarteraVigente, isnull(f4.VarBono ,0) BonoxCrecimientoCartera,          
       isnull(f1.VarBono ,0) + (isnull(f2.VarBono ,0)*b.nrenovado) + isnull(f3.VarBono ,0)+ isnull(f4.VarBono ,0) TotalxBonos,          
       isnull(f5.VarBono ,0) DeduccionxMorosidad,          
       (isnull(f1.VarBono ,0) + (isnull(f2.VarBono ,0)*b.nrenovado) + isnull(f3.VarBono ,0)+ isnull(f4.VarBono ,0)) - ((isnull(f1.VarBono ,0) + (isnull(f2.VarBono ,0)*nrenovado) + isnull(f3.VarBono ,0)+ isnull(f4.VarBono ,0)) * (isnull(f5.VarBono ,0)/100 
)) TotalBono
,b.s60actual
,0 factor
,(isnull(f1.VarBono ,0) + (isnull(f2.VarBono ,0)*b.nrenovado) + isnull(f3.VarBono ,0)+ isnull(f4.VarBono ,0)) - ((isnull(f1.VarBono ,0) + (isnull(f2.VarBono ,0)*nrenovado) + isnull(f3.VarBono ,0)+ isnull(f4.VarBono ,0)) * (isnull(f5.VarBono ,0)/100 
)) bonofinal
,ANT1SC,ANT1SCm0,ANT2SC,ANT2SCm0
 into tCsRptBonoComunal
 FROM #tmpca2 b          
 LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON b.CrecimientoCtes    between f1.MtoMin and f1.MtoMax and f1.tipo = 12              
 LEFT OUTER JOIN tCsCaFactoresCalcBono f2 ON b.porrenovar         between f2.MtoMin and f2.MtoMax and f2.tipo = 13              
 LEFT OUTER JOIN tCsCaFactoresCalcBono f3 ON b.skactual           between f3.MtoMin and f3.MtoMax and f3.tipo = 14              
 LEFT OUTER JOIN tCsCaFactoresCalcBono f4 ON b.CrecimientoCartera between f4.MtoMin and f4.MtoMax and f4.tipo = 15   --Reasignados en el mes no cuentan      
 LEFT OUTER JOIN tCsCaFactoresCalcBono f5 ON b.moraactual         between f5.MtoMin and f5.MtoMax and f5.tipo = 16          
inner join tcloficinas   o on o.codoficina=b.codoficina          
inner join tclzona       z on z.zona=o.zona          
left outer join tCsEmpleados  e on e.codusuario=b.codasesor          
left outer join tcsclpuestos pu on pu.codigo=e.codpuesto

update tCsRptBonoComunal
set factor=isnull(f.varbono,0),bonofinal=case when f.varbono is null then b.totalbono else b.totalbono*(100-f.varbono)/100 end
from tCsRptBonoComunal b
left outer join tCsCaFactoresCalcBono f on b.s60actual between f.mtomin and f.mtomax and f.tipo=17
      
drop table #tmpca
drop table #tmpca2
          
--SELECT * FROM tCsRptBonoComunal_p110614 ORDER BY nomasesor
--SELECT * FROM tsgUsuarios WHERE codusuario in ('GEM0111691','GAA3105821')  
--select * from tSgCmInfoAuto WHERE IDCOLA>=3
--UPDATE tSgCmInfoAuto SET Activo = 1 WHERE IDCOLA >= 3
--INSERT INTO tSgCmInfoAuto select 21,baseini,0,NULL,'pCsABonoComunalDatos',psto1,psto2,psto3,'BNCM',1 from tSgCmInfoAuto where idcola in (14)
--INSERT INTO tSgCmInfoAuto select 22,baseini,0,NULL,'pCsABonoComunalDatos',psto1,psto2,psto3,'BNCM',1 from tSgCmInfoAuto where idcola in (16)

--INSERT INTO tSgCmInfoAuto select 23,baseini,0,NULL,'pCsABonoComunalDatos',psto1,psto2,psto3,'BNCM',1 from tSgCmInfoAuto where idcola in (16)
--DELETE from tSgCmInfoAuto WHERE IDCOLA =23
--
GO