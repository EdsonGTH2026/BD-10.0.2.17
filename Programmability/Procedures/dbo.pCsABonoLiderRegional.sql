SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsABonoLiderRegional] (@FechaFin SMALLDATETIME)
AS

--DECLARE @FechaFin SMALLDATETIME
--SET @FechaFin = '20140531'
 
DECLARE @FechaIni SMALLDATETIME 
DECLARE @FechaAnt SMALLDATETIME 
DECLARE @Periodo1 VARCHAR(6)
DECLARE @Periodo2 VARCHAR(6)
DECLARE @fec_1ra SMALLDATETIME
DECLARE @fec_2da SMALLDATETIME
DECLARE @FechaIni1 SMALLDATETIME
DECLARE @periodo_1ra VARCHAR(6)

SET @fec_1ra = @FechaFin
SET @Periodo1= dbo.fduFechaATexto(@fec_1ra, 'AAAAMM')
SET @FechaIni1 = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))
SET @fec_2da = DateAdd(d,-1,@FechaIni1)
SET @Periodo2= dbo.fduFechaATexto(@fec_2da, 'AAAAMM')
SET @periodo_1ra=dbo.fdufechaaperiodo(@fec_1ra)
SET @FechaIni = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))
SET @FechaAnt = DateAdd(Day, -1, @FechaIni)
 
--Saldo Cartera Vigente Mes Actual 
CREATE TABLE #CaVigMesAct(Zona CHAR(5), Nombre VARCHAR(50), CodOficina CHAR(5), skVigAct decimal(16,2), NumCtesActNvos INTEGER)
INSERT INTO #CaVigMesAct
SELECT o.Zona, z.Nombre, c.CodOficina, 
sum(cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) skVigAct
,count(distinct(cd.codusuario)) NumCtesActNvos 
FROM tCsCartera c WITH(NOLOCK)
INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo=cd.codprestamo
INNER JOIN tcspadroncarteradet p WITH(NOLOCK) ON p.codprestamo = cd.codprestamo AND p.codusuario = cd.codusuario
INNER JOIN tcloficinas o WITH(NOLOCK) ON o.codoficina= c.codoficina
LEFT OUTER JOIN tClZona z WITH(NOLOCK) ON o.Zona= z.Zona
WHERE c.cartera IN ('ACTIVA')
AND c.Fecha = @FechaFin
GROUP BY o.Zona, z.Nombre, c.CodOficina
 
--Saldo Cartera Vigente Mes Anterior 
CREATE TABLE #CaVigMesAnt(Zona CHAR(5), Nombre VARCHAR(50), CodOficina VARCHAR(5), skVigAnt decimal(16,2),nclientes int)
INSERT INTO #CaVigMesAnt
SELECT o.Zona, z.Nombre, c.CodOficina,sum(cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) skVigAnt
,count(distinct(cd.codusuario)) NumCtesActNvos 
FROM tCsCartera c WITH(NOLOCK)
INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo=cd.codprestamo
INNER JOIN tcspadroncarteradet p WITH(NOLOCK) ON p.codprestamo = cd.codprestamo AND p.codusuario = cd.codusuario
INNER JOIN tcloficinas o WITH(NOLOCK) ON o.codoficina= c.codoficina
LEFT OUTER JOIN tClZona z WITH(NOLOCK) ON o.Zona= z.Zona
WHERE c.cartera IN ('ACTIVA')
AND c.Fecha = @FechaAnt
GROUP BY o.Zona, z.Nombre,c.CodOficina
 
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
--sqm90 decimal(16,4) default(0),
)

INSERT INTO #tmpca (codoficina, nomoficina, codasesor, nomasesor, sc1antes, sc1actual, scantes, scactual)
SELECT o.codoficina, o.nomoficina, c.codasesor,a.nomasesor
,sum(case when c.fecha=@fec_2da then(case when c.nrodiasatraso>0 --and c.nrodiasatraso<61
 	 	 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)else 0 end) s1antes
,sum(case when c.fecha=@fec_1ra then(case when c.nrodiasatraso>0 --and c.nrodiasatraso<61 
 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)else 0 end) s1actual
,sum(case when c.fecha=@fec_2da then (cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) else 0 end) scantes
,sum(case when c.fecha=@fec_1ra then (cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) else 0 end) scactual
FROM tCsCartera c with(nolock)
INNER JOIN tcscarteradet cd with(nolock) on c.fecha = cd.fecha and c.codprestamo = cd.codprestamo
INNER JOIN tcspadroncarteradet p with(nolock) on p.codprestamo = cd.codprestamo and p.codusuario = cd.codusuario
INNER JOIN (SELECT codasesor, nomasesor FROM tCsPadronAsesores with(nolock)) a ON a.codasesor=c.codasesor
INNER JOIN tcloficinas o with(nolock) on o.codoficina = c.codoficina
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
 WHERE c.fecha = @fec_2da
 AND c.cartera = 'ACTIVA'
 GROUP BY c.fecha, c.codoficina,c.codprestamo, c.codasesor
) an ON ac.codprestamo=an.codprestamo and ac.codasesor = an.codasesor
LEFT OUTER JOIN tcscartera cx with(nolock) ON cx.codprestamo=an.codprestamo and cx.fecha=@fec_1ra
LEFT OUTER JOIN (SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50)) j ON cx.codasesor=j.codusuario
LEFT OUTER JOIN (--liquidado
 select distinct codprestamo, cancelacion from tcspadroncarteradet with(nolock)
where estadocalculado='CANCELADO' and dbo.fdufechaaperiodo(cancelacion)=@periodo_1ra
) p ON p.codprestamo=an.codprestamo
WHERE ac.fecha is null
GROUP BY an.fecha, an.codoficina, an.codasesor
) a
INNER JOIN #tmpca t on t.codoficina=a.codoficina and t.codasesor = a.codasesor 


SELECT o.zona, sum(scantes) scantes, sum(scactual) scactual, sum(sc1antes) sc1antes, sum(sc1actual) sc1actual
,sum(isnull(moraantes,0)) moraantes, sum(isnull(moraactual,0)) moraactual, sum(sq0) sq0, sum(sqm0) sqm0
INTO #tmpcaF 
FROM #tmpca t INNER JOIN tcloficinas o ON t.codoficina = o.codoficina GROUP BY o.zona

UPDATE #tmpcaF
SET moraantes= (sc1antes/(case when scantes=0 then 1 else scantes end))*100
,moraactual = case when isnull(scactual,0)+isnull(sqm0,0)+isnull(sq0,0) = 0 then 0
else ((isnull(sc1actual,0)+isnull(sqm0,0)) / (isnull(scactual,0)+isnull(sq0,0)+isnull(sqm0,0)))*100 end 

--AQUI AGREGO EL NUMERO DE CLIENTES
SELECT a.Zona, a.Nombre, sum(a.skVigAct) skVigAct
,sum(a.NumCtesActNvos-isnull(p.nclientes,0)) NumCtesActNvos
INTO #CaVigMesActF
FROM #CaVigMesAct a
left outer join #CaVigMesAnt p on a.zona=p.zona and a.codoficina=p.codoficina
GROUP BY a.Zona, a.Nombre

--select @Periodo1
--select @Periodo2
--select * from #CaVigMesAct
--select * from #CaVigMesAnt

SELECT Zona, sum(skVigAnt) skVigAnt
INTO #CaVigMesAntF
FROM #CaVigMesAnt t
--INNER JOIN tcloficinas o ON t.codoficina = o.codoficina
GROUP BY Zona

CREATE TABLE #BonoLR(
  Zona CHAR(5),
  Nombre VARCHAR(50),
  NumCtesActNvos INTEGER,
  skVigAct NUMERIC(16,2),
  skVigAnt NUMERIC(16,2),
  MoraAct NUMERIC(16,2),
  MoraAnt NUMERIC(16,2)
)

INSERT INTO #BonoLR
SELECT act.Zona, act.Nombre, act.NumCtesActNvos, act.skVigAct, ant.skVigAnt, mo.MoraActual, mo.MoraAntes
FROM #CaVigMesActF act 
LEFT OUTER JOIN #CaVigMesAntF ant ON act.zona = ant.zona
LEFT OUTER JOIN #tmpcaF mo ON act.zona = mo.zona
ORDER BY act.Zona
 
CREATE TABLE #BonoSK(
  Zona CHAR(5),
  Nombre VARCHAR(50),
  NumCtesActNvos INTEGER,
  skVigAct NUMERIC(16,2),
  skVigAnt NUMERIC(16,2),
  PorCrecSK DECIMAL(10,1),
  MoraAct NUMERIC(16,2),
  MoraAnt NUMERIC(16,2),
  PorMoraTablaA NUMERIC(16,2),
  PorMoraTablaB NUMERIC(16,2)
)

INSERT INTO #BonoSK
SELECT Zona, Nombre, NumCtesActNvos, skVigAct, skVigAnt, 
  case when (skVigAct-skVigAnt) <= 0 then 0 else cast(((skVigAct-skVigAnt)/skVigAct) * 100 as decimal(10,1)) end PorCrecSK,
  MoraAct, MoraAnt,
  case when MoraAct = 0 and MoraAnt = 0 then 0 else 100-MoraAct end PorMoraTablaA, 
  MoraAnt - MoraAct PorMoraTablaB
FROM #BonoLR 
ORDER BY Zona
 
UPDATE #BonoSK SET PorMoraTablaA = 0 WHERE PorMoraTablaA < 0
--SELECT * FROM #BonoSK WHERE PorMoraTablaA < 0
IF  EXISTS (SELECT * FROM tCsRptBonoliderregional) --dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptBonoCartera]'))-- AND type = 'D')          
BEGIN
    DROP TABLE tCsRptBonoliderregional
END

select z.*,f3.varbono penalizacion,f4.varbono bono
into tCsRptBonoliderregional
from
(
SELECT b.Zona, b.Nombre NombreZona,
 skVigAnt SaldoCarteraAnterior, skVigAct SaldoCarteraActual, f1.VarBono BonoxCrecimientoCartera,
 NumCtesActNvos NumClientesNuevos, case when NumCtesActNvos<=200 then 0 else NumCtesActNvos*20 end BonoxClientesNuevos, 
 MoraAnt MoraMesAnt, MoraAct MoraMesAct,
 tt.Operando TipoTablaParaNormalidad
 --b.PorMoraTablaA NormalidadTablaA, case when tt.Operando = 'A' then isnull(f3.VarBono,0) else NULL end PorcDeduccXNormalidadTablaA,
 --b.PorMoraTablaB ReduccNormTablaB, case when tt.Operando = 'B' then isnull(f4.VarBono,0) else NULL end BonoXReduccNormalidadTablaB
--,cast(((MoraAct-MoraAnt)/MoraAnt)*100 as decimal(10,2)) MargenMora
,case when tt.Operando = 'A' then 100-MoraAct else null end MargenTablaA
,case when tt.Operando = 'B' 
  then (case when cast(((MoraAct-MoraAnt)/MoraAnt)*100 as decimal(10,2))>=0 then 0 else abs(cast(((MoraAct-MoraAnt)/MoraAnt)*100 as decimal(10,2))) end) 
  else null end MargenTablaB
FROM #BonoSK b
LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON b.PorCrecSK between f1.MtoMin and f1.MtoMax and f1.tipo = 8
LEFT OUTER JOIN tCsBsMetaxUEN tt ON b.Zona = tt.NCamValor and tt.iCodIndicador = 10
where b.zona<>'ZCO'
) z
LEFT OUTER JOIN tCsCaFactoresCalcBono f3 ON z.MargenTablaA between f3.MtoMin and f3.MtoMax and f3.tipo = 9 
LEFT OUTER JOIN tCsCaFactoresCalcBono f4 ON z.MargenTablaB between f4.MtoMin and f4.MtoMax and f4.tipo = 11
ORDER BY Zona
 --select * from tcloficinas where codoficina in ('13','20','22','27','29','30',34,71,72,73,77,78,82,83)
 
--select * from tCsCaFactoresCalcBono where tipo = 9 
--select * from tCsCaFactoresCalcBono where tipo = 8
--select * from tCsBsMetaxUEN order by iCodTipoBS

drop table #CaVigMesAct
drop table #CaVigMesAnt
drop table #CaVigMesActF
drop table #CaVigMesAntF
drop table #BonoSK 
drop table #BonoLR
drop table #tmpca
drop table #tmpcaF
GO