SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext pCsABonoCartera        
--DROP PROC pCsABonoCartera            
--EXEC pCsABonoCartera '20140409',''            
CREATE PROCEDURE [dbo].[pCsABonoCartera]            
               ( @fecha      SMALLDATETIME ,            
                 @codoficina VARCHAR(300)  )            
AS        
--*/
/*           
declare @fecha SMALLDATETIME            
    set @fecha = '20140409'            
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
--print @FechaIni1
SET @fec_2da   = DateAdd(d,-1,@FechaIni1)
--print @fec_2da

SET @Periodo2  = dbo.fduFechaATexto(@fec_2da, 'AAAAMM')
SET @FechaIni2 = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo2 + '01' As SmallDateTime)))
--print @FechaIni2
SET @fec_3ra   = DateAdd(d,-1,@FechaIni2)
--print @fec_3ra
SET @Periodo3  = dbo.fduFechaATexto(@fec_3ra, 'AAAAMM')

set @fec_4ta = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo3 + '01' As SmallDateTime)))

SET @MesAñoAnt = CONVERT(CHAR(4),YEAR(@FechaIni2))+CONVERT(CHAR(2),(CASE WHEN LEN(MONTH(@FechaIni2))= 1 THEN '0'+CONVERT(CHAR(1),MONTH(@FechaIni2)) ELSE CONVERT(CHAR(2),MONTH(@FechaIni2)) END))
--print @MesAñoAnt

declare @periodo_1ra varchar(6)
declare @periodo_2da varchar(6)
declare @periodo_3ra varchar(6)
declare @periodo_4ta varchar(6)
set @periodo_1ra=dbo.fdufechaaperiodo(@fec_1ra)
set @periodo_2da=dbo.fdufechaaperiodo(@fec_2da)
set @periodo_3ra=dbo.fdufechaaperiodo(@fec_3ra)
set @periodo_4ta=dbo.fdufechaaperiodo(@fec_4ta)

create table #tmpca(
  codoficina varchar(4),
  nomoficina varchar(250),
  codasesor varchar(15),
  nomasesor varchar(250),
  duplicado int default(0),
  ncliante int default(0),
  ncliactu int default(0),
  skantes decimal(16,4),
  skactual decimal(16,4),
  scantes decimal(16,4),
  scactual decimal(16,4),
  sc1antes decimal(16,4),
  sc1actual decimal(16,4),
  nnewcliante int default(0),
  nnewcliactu int default(0),
  snantes decimal(16,4),
  snactual decimal(16,4),
  s60antes decimal(16,4),
  s60actual decimal(16,4),
  n60antes int default(0),
  n60actual int default(0),
  moraantes decimal(16,2),
  moraactual decimal(16,2),
  nasignado int default(0),
  sasignado decimal(16,4) default(0),
  nrenovado int default(0),
  nrenovadoU int default(0),
  srenovado decimal(16,4) default(0),
  squitado decimal(16,4) default(0),
  nquitado int default(0),
  sq0 decimal(16,4) default(0),
  sqm0 decimal(16,4) default(0),
  sqm90 decimal(16,4) default(0),
  sjuridico decimal(16,4) default(0),
  nliquidado int default(0),
  sliquidado decimal(16,4) default(0),
  
  porrenovar int default(0),
  nreasignado int default(0),
  sreasignado decimal(16,4) default(0),
  sreasignadom0 decimal(16,4) default(0),

  ANT1SC int default(0),
  ANT1SCm0 int default(0),  
  ANT2SC int default(0),
  ANT2SCm0 int default(0)
)
--verificar que sea el primer asesor el que coloco?????            
insert into #tmpca (codoficina, nomoficina, codasesor, nomasesor, skantes, skactual, snantes, snactual, s60antes, s60actual            
, sc1antes, sc1actual,scantes,scactual,ncliante,ncliactu,nnewcliante,nnewcliactu,n60antes,n60actual)        
SELECT o.codoficina, o.nomoficina, c.codasesor,a.nomasesor--c.fecha,             
--,sum(cd.saldocapital) saldocapital            
,sum(case when c.fecha=@fec_2da then (case when c.nrodiasatraso<61 then cd.saldocapital else 0 end) else 0 end) skantes            
,sum(case when c.fecha=@fec_1ra then (case when c.nrodiasatraso<61 then cd.saldocapital else 0 end) else 0 end) skactual            
--,sum(case when p.secuenciacliente=1 then cd.saldocapital else 0 end) saldonuevo            
,sum(case when c.fecha=@fec_2da then(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@periodo_2da and p.tiporeprog='SINRE' then cd.montodesembolso else 0 end)else 0 end) snantes            
,sum(case when c.fecha=@fec_1ra then(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@periodo_1ra and p.tiporeprog='SINRE' then cd.montodesembolso else 0 end)else 0 end) snactual            
--,sum(case when c.nrodiasatraso>=60 then cd.saldocapital else 0 end) saldo60            
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
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo            
inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario            
inner join (            
  SELECT codasesor, nomasesor FROM tCsPadronAsesores with(nolock) --where activo=1 and activoactual=1            
              
) a on a.codasesor=c.codasesor            
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina            
where c.fecha in (@fec_2da,@fec_1ra)            
and c.cartera='ACTIVA'    
And c.codproducto <> '164'        
--and c.nrodiasatraso<=60        
--aqui quita a juridico, 41:lideres,59: coordinador administrativo
and c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50,41,59,70,62,71,64))
--and c.codasesor='AHJ2110851'            
group by o.codoficina, o.nomoficina, c.codasesor, a.nomasesor--c.fecha,             
order by o.codoficina            
            
--REASIGNACION : CARTERA ASIGNADA - PERIODO ACTUAL            
--select fecha, codasesor, asignado             
update #tmpca
set sasignado=asignado-renovacion,srenovado=renovacion
,nrenovado=nrenova
,nrenovadoU=nrenovaU
,nasignado=a.nasignado-nrenova
,nreasignado = a.nreasignado
,sreasignado = a.sreasignado
,sreasignadom0 = a.sreasignadom0
from (            
select ac.fecha,ac.codasesor,sum(ac.saldocapital) asignado        
,sum(ac.nasignado) + sum(ac.nrenovaU) nasignado --sum(ac.nasignado)
,sum(ac.renovacion) renovacion
,sum(ac.nrenova) nrenova
,sum(ac.nrenovaU) nrenovaU
,sum(ac.nasignado) nreasignado --sum(ac.nasignado)-sum(ac.nrenova)        
,sum(ac.sreasignado) sreasignado
,sum(ac.sreasignadom0) sreasignadom0
from(
  SELECT c.fecha, c.codprestamo, c.codasesor        
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
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario        
  where c.fecha=@fec_1ra        
  and c.cartera='ACTIVA' 
  And c.codproducto <> '164'
  --and c.codasesor='ACA2210801'        
  --and p.secuenciacliente<>1        
  and c.nrodiasatraso<61        
  group by c.fecha, c.codprestamo, c.codasesor        
) ac        
left outer join (        
--40 toda la cartera en agosto        
--28 quitando los nuevos        
  SELECT c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital) saldocapital        
  FROM tCsCartera c with(nolock)        
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo        
  --inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario        
  where c.fecha=@fec_2da        
  and c.cartera='ACTIVA' 
  and c.codproducto <> '164'        
  --and c.codasesor='ACA2210801'        
  group by c.fecha, c.codprestamo, c.codasesor        
) an        
on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor      
where an.fecha is null        
group by ac.fecha,ac.codasesor        
) a            
inner join #tmpca t on t.codasesor=a.codasesor
            
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
    and c.codproducto <> '164'
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
    and c.codproducto <> '164'
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
    and c.codproducto <> '164'
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
    and c.codproducto <> '164'
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
update #tmpca            
set squitado=quitado-liquidacion-juridico,sjuridico=juridico,sq0=q0,sqm0=qm0,sqm90=qm90            
,sliquidado=liquidacion,nliquidado=nliquidacion,nquitado=a.nquitado        
from (            
select an.fecha,an.codasesor,sum(an.saldocapital) quitado--an.saldocapital--an.codprestamo            
--,cx.codasesor,cx.nrodiasatraso,cx.estado,cx.fechadesembolso            
--,ac.fecha,ac.codprestamo,ac.codasesor,ac.saldocapital            
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
from(            
  SELECT c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital) saldocapital            
  FROM tCsCartera c with(nolock)            
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo            
  inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario            
  where c.fecha=@fec_1ra        
  and c.cartera='ACTIVA'            
  and c.codproducto <> '164'        
  --and c.codasesor='MML1305781'--'AHJ2110851'        
  group by c.fecha, c.codprestamo, c.codasesor            
) ac            
right outer join (            
--40 toda la cartera en agosto            
--28 quitando los nuevos            
  SELECT c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocapital            
  ,sum(case when c.nrodiasatraso=0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) q0            
  ,sum(case when c.nrodiasatraso>0 and c.nrodiasatraso<91 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) qm0            
  ,sum(case when c.nrodiasatraso>90 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) qm90--aqui creo poner:c.nrodiasatraso<91            
  ,count(distinct cd.codusuario) nroclientes        
  FROM tCsCartera c with(nolock)      inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo            
  --inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario            
  where c.fecha=@fec_2da            
  and c.cartera='ACTIVA'            
  and c.codproducto <> '164'        
  --and c.codasesor='MML1305781'--'AHJ2110851'        
  group by c.fecha, c.codprestamo, c.codasesor            
) an            
on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor            
left outer join tcscartera cx with(nolock)            
on cx.codprestamo=an.codprestamo and cx.fecha=@fec_1ra            
left outer join (SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50)) j            
on cx.codasesor=j.codusuario            
left outer join (--liquidado            
    select distinct codprestamo, cancelacion from tcspadroncarteradet with(nolock)            
    where estadocalculado='CANCELADO'  and codproducto <> '164' and dbo.fdufechaaperiodo(cancelacion)=@periodo_1ra            
) p on p.codprestamo=an.codprestamo            
where ac.fecha is null            
--and cx.codprestamo is not null            
group by an.fecha,an.codasesor            
) a            
inner join #tmpca t on t.codasesor=a.codasesor            
            
/*CLIENTES POR RENOVAR EN EL MES*/            
--Aqui se considero todos los clientes con fecha de vencimiento en el periodo o que haigan cancelado en el periodo            
update #tmpca            
set porrenovar=a.porrenovar            
from (            
select p.últimoasesor codasesor,count(p.codprestamo) porrenovar    --codusuario        
from tcspadroncarteradet p with(nolock)            
inner join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha            
where dbo.fdufechaaperiodo(c.fechavencimiento)=@MesAñoAnt--'201401' --fechavencimiento>='20140101' and fechavencimiento<='20140131'            
and p.estadocalculado<>'CASTIGADA'  
  and c.codproducto <> '164'        
and c.nrodiasatraso<61            
and (p.cancelacion is null            
or dbo.fdufechaaperiodo(p.cancelacion)=@MesAñoAnt)--'201401')            
group by p.últimoasesor            
) a            
inner join #tmpca t on t.codasesor=a.codasesor            
            
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
            
update #tmpca            
set duplicado=nro            
from (            
select nomasesor,count(nomasesor) nro            
from #tmpca            
group by nomasesor            
having count(nomasesor)>1            
) a            
inner join #tmpca b on a.nomasesor=b.nomasesor            

/*--181            
select --@fec_1ra as fecha,            
       p.codoficina,p.nomoficina,z.nombre region,p.codasesor,p.nomasesor,pu.Descripcion puesto,p.duplicado,            
p.ncliante-p.VANTasignado-p.VANTasignado CliAnt,p.nnewcliactu,p.nliquidado, (p.ncliante-p.VANTasignado-p.VANTasignado) + p.nnewcliactu - p.nliquidado ClientesTotales            
,p.nrenovado, p.porrenovar clientesArenovarenmes, case when p.porrenovar=0 then 0 else cast((cast(p.nrenovado as decimal(10,2))/cast(p.porrenovar as decimal(10,2)))*100 as decimal(10,2)) end porrenova            
,p.skantes,p.skactual, p.skactual - p.skantes CrecimientoCartera            
,p.moraactual            
            
--ncliante,ncliactu,nnewcliante,moraantes,            
from #tmpca p             
inner join tcloficinas o on o.codoficina=p.codoficina            
inner join tclzona z on z.zona=o.zona            
inner join tCsEmpleados e on e.codusuario=p.codasesor            
inner join tcsclpuestos pu on pu.codigo=e.codpuesto            
            
            
*/            
              
create table #tmpca2(            
  codoficina varchar(4),            
  nomoficina varchar(250),            
  codasesor varchar(15),            
  nomasesor varchar(250),            
  duplicado int default(0),            
  cliAnt    int default(0),--decimal(16,4),            
  nnewcliactu int default(0),            
  nliquidado int default(0),            
  ClientesTotales  numeric(16),             
  CrecimientoCtes  numeric(16),             
  nrenovado int default(0),        
  nrenovadoU int default(0),        
  clientesArenovarenmes int default(0),            
  porrenovar int default(0),            
  skantes decimal(16,4),            
  skactual decimal(16,4),            
  CrecimientoCartera decimal(16,4),            
  moraactual decimal(16,2),        
  nreasignado int default(0),        
  sreasignado decimal(16,2),
  sreasignadom0 decimal(16,2),
  ncliante int default(0),
  ncliactu int default(0),
  nquitado int default(0),
  n60antes int default(0),
  n60actual int default(0),
  s60antes decimal(16,4),
  s60actual decimal(16,4),
  ANT1SC int default(0),
  ANT1SCm0 int default(0),
  ANT2SC int default(0),
  ANT2SCm0 int default(0)
  )         
            
INSERT INTO #tmpca2
select p.codoficina, p.nomoficina, p.codasesor, p.nomasesor, p.duplicado,
       --p.ncliante-p.VANTasignado-p.VANTasignado CliAnt,
       ncliante As CliAnt,
       p.nnewcliactu,
       p.nliquidado,
      --(p.ncliante-p.VANTasignado-p.VANTasignado) + p.nnewcliactu - p.nliquidado ClientesTotales,
      ncliante + p.nnewcliactu - p.nliquidado ClientesTotales,
      (p.nnewcliactu - p.nliquidado) CrecimientoCtes,
      p.nrenovado,p.nrenovadoU, isnull(r.ValorProg,0) clientesArenovarenmes,   --p.porrenovar clientesArenovarenmes,

      case when isnull(r.ValorProg,0) = 0 --p.porrenovar=0
           then case when p.nrenovado > 0
                     then 100
                     else 0
                     end
           else
                case when cast((cast(p.nrenovado as decimal(10,2))/cast(isnull(r.ValorProg,0) as decimal(10,2)))*100 as decimal(10,2)) > 100 --cast((cast(p.nrenovado as decimal(10,2))/cast(p.porrenovar as decimal(10,2)))*100 as decimal(10,2)) > 100
                     then 100
                     else cast((cast(p.nrenovado as decimal(10,2))/cast(isnull(r.ValorProg,0) as decimal(10,2)))*100 as decimal(10,2))       --cast((cast(p.nrenovado as decimal(10,2))/cast(p.porrenovar as decimal(10,2)))*100 as decimal(10,2))
                      end
            end
            porrenova
      --,p.skantes, p.skactual, p.skactual - p.skantes CrecimientoCartera
      --,p.scantes skantes, p.scactual skactual, p.scactual - p.scantes CrecimientoCartera
      ,p.scantes skantes, p.scactual skactual, (p.scactual-sreasignado-ANT1SC) - (p.scantes-ANT1SC) CrecimientoCartera
      ,p.moraactual
      ,p.nreasignado, p.sreasignado, p.sreasignadom0
      ,ncliante
      ,ncliactu,nquitado
      ,n60antes,n60actual
	,s60antes,s60actual
	,ANT1SC,ANT1SCm0,ANT2SC,ANT2SCm0
 from #tmpca p
 left outer join tCsBsMetaxUEN r on rtrim(r.NCamValor) = p.codasesor and r.iCodIndicador = 8
and r.fecha=(select ultimodia from tclperiodo where periodo=@Periodo1)
order by p.codasesor
--select * from tCsBsMetaxUEN where icodtipobs = 8      
      
IF  EXISTS (SELECT * FROM tCsRptBonoCartera) --dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptBonoCartera]'))-- AND type = 'D')            
BEGIN            
     DROP TABLE tCsRptBonoCartera
END            

SELECT @fec_1ra as fecha,
       b.codoficina,b.nomoficina,z.nombre region,b.codasesor,b.nomasesor,
       e.Ingreso FechaIngreso,
       dbo.fCsAntiguedad(e.Ingreso,getdate()) Antiguedad,
       --cast(datediff(month,e.Ingreso,getdate()) as varchar(6)) Antiguedad,
       e.CodEmpleado NumEmpleado, pu.Descripcion puesto,case when e.estado=1 then 'ACTIVO' else 'BAJA' end EstadoAsesor,b.duplicado
       --,ncliante
       --,n60antes
       ,ncliactu
       ,n60actual
       ,nquitado
       ,case when b.cliAnt < 0 then 0 else b.cliAnt end CtesMesAnt
       , b.nnewcliactu CtesNvos, b.nliquidado,
       case when b.ClientesTotales < 0 then 0 else b.ClientesTotales end ClientesTotales, b.CrecimientoCtes,
       b.nreasignado, b.sreasignado, b.sreasignadom0,
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
 into tCsRptBonoCartera
 FROM #tmpca2 b            
 LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON b.CrecimientoCtes    between f1.MtoMin and f1.MtoMax and f1.tipo = 1                
 LEFT OUTER JOIN tCsCaFactoresCalcBono f2 ON b.porrenovar         between f2.MtoMin and f2.MtoMax and f2.tipo = 2                
 LEFT OUTER JOIN tCsCaFactoresCalcBono f3 ON (b.skactual-b.sreasignado-b.ANT1SC)--b.skactual           
between f3.MtoMin and f3.MtoMax and f3.tipo = 3                
 LEFT OUTER JOIN tCsCaFactoresCalcBono f4 ON b.CrecimientoCartera between f4.MtoMin and f4.MtoMax and f4.tipo = 4   --Reasignados en el mes no cuentan        
 LEFT OUTER JOIN tCsCaFactoresCalcBono f5 ON b.moraactual         between f5.MtoMin and f5.MtoMax and f5.tipo = 5            
inner join tcloficinas  o on o.codoficina=b.codoficina            
inner join tclzona      z on z.zona=o.zona            
left outer join tCsEmpleados e on e.codusuario=b.codasesor            
left outer join tcsclpuestos pu on pu.codigo=e.codpuesto        
        
update tCsRptBonoCartera
set factor=isnull(f.varbono,0),bonofinal=case when f.varbono is null then b.totalbono else b.totalbono*(100-f.varbono)/100 end
from tCsRptBonoCartera b
left outer join tCsCaFactoresCalcBono f on b.s60actual between f.mtomin and f.mtomax and f.tipo=17

--select * from tCsCaFactoresCalcBono where tipo = 2
--select * from tCsEmpleados

--select * from tCsCaFactoresCalcBono where tipo = 4
drop table #tmpca
drop table #tmpca2

--SELECT * FROM tCsRptBonoCartera_p050614 ORDER BY nomasesor
GO