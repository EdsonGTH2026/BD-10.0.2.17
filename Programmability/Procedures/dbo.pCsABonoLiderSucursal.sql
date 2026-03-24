SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsABonoLiderSucursal] (@FechaFin SMALLDATETIME)
AS

--DECLARE @FechaFin SMALLDATETIME
--SET @FechaFin = '20140531'
       
DECLARE @FechaIni SMALLDATETIME   
DECLARE @FechaAnt SMALLDATETIME 
DECLARE @Periodo1 VARCHAR(6)      
DECLARE @fec_1ra     SMALLDATETIME      
DECLARE @fec_2da     SMALLDATETIME      
DECLARE @FechaIni1   SMALLDATETIME        
DECLARE @periodo_1ra VARCHAR(6)
DECLARE @periodo_2da VARCHAR(6)
      
SET @fec_1ra   = @FechaFin
SET @Periodo1  = dbo.fduFechaATexto(@fec_1ra, 'AAAAMM')
SET @FechaIni1 = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))
SET @fec_2da   = DateAdd(d,-1,@FechaIni1)
SET @periodo_1ra=dbo.fdufechaaperiodo(@fec_1ra)
SET @FechaIni = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))
SET @FechaAnt = DateAdd(Day, -1, @FechaIni)
set @periodo_2da=dbo.fdufechaaperiodo(@fec_2da)
--Saldo Cartera Vigente Mes Actual 
CREATE TABLE #CaVigMesAct(CodOficina CHAR(5), NombreOf VARCHAR(30), NumAsesores INTEGER default(0), skVigAct NUMERIC(16,2), NumCtesActNvos INTEGER)
INSERT INTO #CaVigMesAct (CodOficina, NombreOf, skVigAct, NumCtesActNvos)
SELECT o.CodOficina, o.NomOficina,
--count(distinct c.codasesor) NumAsesores,
sum(cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) skVigAct,
--count(distinct(case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@Periodo1 and p.tiporeprog='SINRE'
--      then p.codusuario
--      else null
--      end)) 
count(distinct(cd.codusuario)) NumCtesActNvos
FROM tCsCartera c WITH(NOLOCK)
INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo=cd.codprestamo
INNER JOIN tcspadroncarteradet p WITH(NOLOCK) ON p.codprestamo = cd.codprestamo AND p.codusuario = cd.codusuario
left outer join tCsCarteraSuCe sc with(nolock) on sc.codprestamo=c.codprestamo
INNER JOIN tcloficinas o WITH(NOLOCK) 
ON o.codoficina=(
                case when sc.codoficina is null 
                then 
                (
                  case when c.codoficina='20' then '19'
                  when c.codoficina='71' then '14'
                  else c.codoficina end
                )
                else sc.codoficina end
                )--isnull(sc.codoficina,c.codoficina)
WHERE c.cartera IN ('ACTIVA')  
AND c.Fecha = @FechaFin
GROUP BY o.CodOficina,o.NomOficina

update #CaVigMesAct
set NumAsesores=e.nro
from #CaVigMesAct a
inner join (
  select codoficinanom,count(codoficinanom) nro
  from tcsempleados
  where estado=1 and codpuesto in (66,67,47,48,49,5,6,7,8,9)
  group by codoficinanom
) e on e.codoficinanom=a.codoficina

--drop table #CaVigMesAct
 
--Saldo Cartera Vigente Mes Anterior 
CREATE TABLE #CaVigMesAnt(CodOficina CHAR(5), skVigAnt NUMERIC(16,2), NumCtesAntNvos INTEGER)
INSERT INTO #CaVigMesAnt
select codoficina,sum(skVigAnt) skVigAnt,count(distinct(NumCtesAntNvos)) NumCtesAntNvos
from (
  SELECT --isnull(sc.codoficina,c.CodOficina) CodOficina
  case when sc.codoficina is null 
                then 
                (
                  case when c.codoficina='20' then '19' 
                  when c.codoficina='71' then '14'
                  else c.codoficina end
                )
                else sc.codoficina end CodOficina
  ,cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido skVigAnt
  --,case when p.secuenciacliente=1 and dbo.fdufechaAperiodo(p.desembolso)=@Periodo_2da and p.tiporeprog='SINRE'
  --    then p.codusuario
  --    else null end NumCtesAntNvos
,cd.codusuario NumCtesAntNvos
  FROM tCsCartera c WITH(NOLOCK)
  INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo=cd.codprestamo
  INNER JOIN tcspadroncarteradet p WITH(NOLOCK) ON p.codprestamo = cd.codprestamo AND p.codusuario = cd.codusuario
  left outer join tCsCarteraSuCe sc with(nolock) on sc.codprestamo=c.codprestamo
  WHERE c.cartera IN ('ACTIVA') AND c.Fecha = @FechaAnt
) a
GROUP BY CodOficina
 
--OBTENIENDO MORA
CREATE TABLE #tmpca(      
  codoficina varchar(4),      
  nomoficina varchar(250),      
  codasesor varchar(15),      
  nomasesor varchar(250),      
  scantes decimal(16,4),      
  scactual decimal(16,4),      
  sc1antes decimal(16,4),      
  sc1actual decimal(16,4),      
  moraantes decimal(16,2),      
  moraactual decimal(16,2),      
  sq0 decimal(16,4) default(0),      
  sqm0 decimal(16,4) default(0),      
--  sqm90 decimal(16,4) default(0),      
)      

INSERT INTO #tmpca (codoficina, nomoficina, codasesor, nomasesor, sc1antes, sc1actual, scantes, scactual)  
SELECT o.codoficina, o.nomoficina, c.codasesor,a.nomasesor
	   ,sum(case when c.fecha=@fec_2da then(case when c.nrodiasatraso>0
 	   	         then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)else 0 end) s1antes      
       ,sum(case when c.fecha=@fec_1ra then(case when c.nrodiasatraso>0
                 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)else 0 end) s1actual      
	   ,sum(case when c.fecha=@fec_2da then (cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) else 0 end) scantes      
	   ,sum(case when c.fecha=@fec_1ra then (cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) else 0 end) scactual       
 FROM tCsCartera c with(nolock)      
INNER JOIN tcscarteradet      cd with(nolock) on c.fecha = cd.fecha and c.codprestamo = cd.codprestamo      
INNER JOIN tcspadroncarteradet p with(nolock) on p.codprestamo = cd.codprestamo and p.codusuario = cd.codusuario      
INNER JOIN (
  SELECT codasesor, nomasesor FROM tCsPadronAsesores with(nolock)
) a ON a.codasesor=c.codasesor      
INNER JOIN tcloficinas        o with(nolock) on o.codoficina = c.codoficina      
WHERE c.fecha in (@fec_2da, @fec_1ra)      
  AND c.cartera='ACTIVA'      
GROUP BY o.codoficina, o.nomoficina, c.codasesor,a.nomasesor
ORDER BY o.codoficina 

UPDATE #tmpca      
   SET sq0=q0,sqm0=qm0
  FROM (Select an.Fecha, an.codoficina, an.codasesor      
		 	   ,sum(case when p.cancelacion is null 
			  		     then case when j.codusuario is not null 
								   then 0 
								   else an.q0 
								   end 
					     else 0 end) q0      
               ,sum(case when p.cancelacion is null 
                         then (case when j.codusuario is not null 
                                    then 0 
                                    else an.qm0 
                                    end      
                               ) 
                         else 0 end) qm0      
          From(select c.fecha, c.codoficina, c.codasesor, c.codprestamo, sum(cd.saldocapital) saldocapital      
                 from tCsCartera c with(nolock)      
                inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo      
                inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario      
                where c.fecha=@fec_1ra  
                  and c.cartera='ACTIVA'      
             group by c.fecha, c.codoficina, c.codprestamo, c.codasesor      
) ac      
RIGHT OUTER JOIN (SELECT c.fecha, c.codoficina, c.codasesor, c.codprestamo
                         ,sum(case when c.nrodiasatraso=0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) q0      
                         ,sum(case when c.nrodiasatraso>0 and c.nrodiasatraso<91 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) qm0      
                    FROM tCsCartera c with(nolock)      
                   INNER JOIN tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo      
                   WHERE c.fecha   = @fec_2da      
                     AND c.cartera = 'ACTIVA'      
                   GROUP BY c.fecha, c.codoficina,c.codprestamo, c.codasesor
                  ) an  ON ac.codprestamo=an.codprestamo and ac.codasesor = an.codasesor
LEFT OUTER JOIN tcscartera cx with(nolock) ON cx.codprestamo=an.codprestamo and cx.fecha=@fec_1ra      
LEFT OUTER JOIN (SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50)) j ON cx.codasesor=j.codusuario      
LEFT OUTER JOIN (--liquidado      
                 select distinct codprestamo, cancelacion from tcspadroncarteradet with(nolock)      
                  where estadocalculado='CANCELADO' and dbo.fdufechaaperiodo(cancelacion)=@periodo_1ra      
                ) p ON p.codprestamo=an.codprestamo      
WHERE ac.fecha is null      
--and cx.codprestamo is not null      
GROUP BY an.fecha, an.codoficina, an.codasesor    
) a      
INNER JOIN #tmpca t on t.codoficina=a.codoficina and t.codasesor = a.codasesor 

SELECT codoficina, sum(scantes) scantes, sum(scactual) scactual, sum(sc1antes) sc1antes, sum(sc1actual) sc1actual, 
       sum(isnull(moraantes,0)) moraantes, sum(isnull(moraactual,0)) moraactual, sum(sq0) sq0, sum(sqm0) sqm0
INTO #tmpcaF
FROM #tmpca t
GROUP BY codoficina
 --select * from #tmpcaF

UPDATE #tmpcaF      
SET moraantes  = case when isnull(scantes,0)=0 then 0 else (isnull(sc1antes,0)/isnull(scantes,0))*100 end-- (sc1antes/(case when isnull(scantes,0)=0 then 1 else scantes end))*100
    ,moraactual = case when isnull(scactual,0)=0 then 0
                         else (isnull(sc1actual,0)/isnull(scactual,0))*100 end
 
CREATE TABLE #BonoSK(CodOficina CHAR(5), NombreOf VARCHAR(30), NumAsesores INTEGER, NumCtesActNvos INTEGER, skVigAct NUMERIC(16,2), skVigAnt NUMERIC(16,2), 
                     PorCrecSK DECIMAL(10,1), MoraAct NUMERIC(16,2), MoraAnt NUMERIC(16,2), PorMoraTablaA NUMERIC(16,2), PorMoraTablaB NUMERIC(16,2) )
INSERT INTO #BonoSK
SELECT act.CodOficina, act.NombreOf, act.NumAsesores, (act.NumCtesActNvos - ant.NumCtesAntNvos) NumCtesActNvos , skVigAct, skVigAnt, 
       case when (skVigAct-skVigAnt) <= 0 then 0 else cast(((skVigAct-skVigAnt)/skVigAnt) * 100 as decimal(10,1)) end PorCrecSK,
       MoraActual, MoraAntes,
       case when MoraActual = 0 and MoraAntes = 0 then 0 else 100-mo.MoraActual end PorMoraTablaA, 
       case when MoraAntes=0 then 0 else ((MoraAntes-MoraActual)/MoraAntes)*100 end PorMoraTablaB
       --case when (MoraAct-MoraAnt) <= 0 then 0 else cast(((MoraAct-MoraAnt)/MoraAct) * 100 as decimal(10,1)) end PorMoraTablaB
FROM #CaVigMesAct act 
LEFT OUTER JOIN #CaVigMesAnt ant ON act.codoficina = ant.codoficina
LEFT OUTER JOIN #tmpcaF mo ON act.codoficina = mo.codoficina
ORDER BY act.codoficina

--SELECT act.CodOficina, act.NombreOf, act.NumAsesores,act.NumCtesActNvos,ant.NumCtesAntNvos,(act.NumCtesActNvos - ant.NumCtesAntNvos) NumCtesActNvos
--FROM #CaVigMesAct act 
--LEFT OUTER JOIN #CaVigMesAnt ant ON act.codoficina = ant.codoficina
--LEFT OUTER JOIN #tmpcaF mo ON act.codoficina = mo.codoficina
--ORDER BY act.codoficina

 
--UPDATE #BonoSK SET PorMoraTablaA = 0 WHERE PorMoraTablaA < 0
--SELECT * FROM #BonoSK WHERE PorMoraTablaA < 0
 
IF  EXISTS (SELECT * FROM tCsRptBonolidersucursal) --dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptBonoCartera]'))-- AND type = 'D')          
BEGIN
    DROP TABLE tCsRptBonolidersucursal
END
 
SELECT b.CodOficina, b.NombreOf AS Oficina,
       skVigAnt SaldoCarteraAnterior, skVigAct SaldoCarteraActual, f1.VarBono BonoxCrecimientoCartera,
       NumAsesores, NumCtesActNvos NumClientesNuevos,
--case NumAsesores 
--    when 1  then case when NumCtesActNvos >=3 and NumCtesActNvos  >= 5  then isnull(f2.VarBono,0) else 0 end
--    when 2  then case when NumCtesActNvos >=6 and NumCtesActNvos  >= 8  then isnull(f2.VarBono,0) else 0 end
--    when 3  then case when NumCtesActNvos >=9 and NumCtesActNvos  >= 12 then isnull(f2.VarBono,0) else 0 end
--    when 4  then case when NumCtesActNvos >=13 and NumCtesActNvos >= 16 then isnull(f2.VarBono,0) else 0 end
--    when 5  then case when NumCtesActNvos >=17 and NumCtesActNvos >= 20 then isnull(f2.VarBono,0) else 0 end
--    when 6  then case when NumCtesActNvos >=21 and NumCtesActNvos >= 24 then isnull(f2.VarBono,0) else 0 end
--    when 7  then case when NumCtesActNvos >=25 and NumCtesActNvos >= 28 then isnull(f2.VarBono,0) else 0 end
--    when 8  then case when NumCtesActNvos >=29 and NumCtesActNvos >= 32 then isnull(f2.VarBono,0) else 0 end
--    when 9  then case when NumCtesActNvos >=33 and NumCtesActNvos >= 36 then isnull(f2.VarBono,0) else 0 end
--    when 10 then case when NumCtesActNvos >=37 then isnull(f2.VarBono,0) else 0 end
--end BonoxClientesNuevos,

case when NumCtesActNvos >=3 and NumCtesActNvos  <= 5 then
          case when NumAsesores<=1 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=6 and NumCtesActNvos  <= 8 then
          case when NumAsesores<=2 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=9 and NumCtesActNvos  <= 12 then 
          case when NumAsesores<=3 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=13 and NumCtesActNvos <= 16 then
          case when NumAsesores<=4 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=17 and NumCtesActNvos <= 20 then
          case when NumAsesores<=5 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=21 and NumCtesActNvos <= 24 then
          case when NumAsesores<=6 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=25 and NumCtesActNvos <= 28 then
          case when NumAsesores<=7 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=29 and NumCtesActNvos <= 32 then
          case when NumAsesores<=8 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=33 and NumCtesActNvos <= 36 then
          case when NumAsesores<=9 then isnull(f2.VarBono,0) else 0 end
     when NumCtesActNvos >=37 then
          case when NumAsesores<=10 then isnull(f2.VarBono,0) else 0 end
     else 0 end BonoxClientesNuevos,

MoraAnt MoraMesAnt, MoraAct MoraMesAct,
tt.Operando TipoTablaParaNormalidad,
PorMoraTablaA NormalidadTablaA, case when tt.Operando = 'A' then isnull(f3.VarBono,0) else 0 end PorcDeduccXNormalidadTablaA,
PorMoraTablaB ReduccNormTablaB, case when tt.Operando = 'B' then isnull(f4.VarBono,0) else 0 end BonoXReduccNormalidadTablaB
into tCsRptBonolidersucursal
FROM #BonoSK b
LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON b.PorCrecSK      between f1.MtoMin and f1.MtoMax and f1.tipo=6
LEFT OUTER JOIN tCsCaFactoresCalcBono f2 ON b.NumCtesActNvos between f2.MtoMin and f2.MtoMax and f2.tipo=7
LEFT OUTER JOIN tCsBsMetaxUEN         tt ON b.codoficina=tt.NCamValor and tt.iCodIndicador=9 --TipoTabla Para Suc   
LEFT OUTER JOIN tCsCaFactoresCalcBono f3 ON b.PorMoraTablaA between f3.MtoMin and f3.MtoMax and f3.tipo=9
LEFT OUTER JOIN tCsCaFactoresCalcBono f4 ON b.PorMoraTablaB between f4.MtoMin and f4.MtoMax and f4.tipo=10
ORDER BY convert(integer, b.codoficina) ASC
 --select * from tcloficinas where codoficina in ('13','20','22','27','29','30',34,71,72,73,77,78,82,83)  
 
--  select tt.Operando, * from tCsCaFactoresCalcBono where tipo = 9   

drop table #CaVigMesAct
drop table #CaVigMesAnt
drop table #BonoSK 
drop table #tmpca
drop table #tmpcaF
--drop table #Mora
GO