SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--EXEC pCaRptCreditosReestructurados '20120501','20130430'
--DROP PROC pCaRptCreditosReestructurados
CREATE PROCEDURE [dbo].[pCaRptCreditosReestructurados]
               ( @FechaIni SMALLDATETIME,
                 @FechaFIn SMALLDATETIME )
AS
/*
DECLARE @FechaIni SMALLDATETIME
DECLARE @FechaFIn SMALLDATETIME
 SELECT @FechaIni = '2012-05-01'
 SELECT @FechaFIn = '2013-03-31'
--*/

--DROP TABLE #CredReest
SELECT DISTINCT CASE WHEN LEN(ca.CodOficina) = 1 THEN '0'+ca.CodOficina ELSE ca.CodOficina END AS CodOficina, O.NomOficina,   
       ca.FechaDesembolso AS Fecha, ca.MontoDesembolso, P.CodPrestamo AS Cuenta, ca.CodUsuario,
       CASE WHEN ca.CodGrupo IS NULL THEN U.NombreCompleto ELSE G.NombreGrupo END AS Nombre,   
       M.DescAbreviada AS Moneda, P.EstadoCalculado Estado, --ca.Estado, 
       ca.CodAnterior, ca.CodSolicitud, ca.CodProducto,   
       CONVERT(CHAR(4),YEAR(ca.FechaDesembolso)) +' - ' + CASE WHEN LEN(RTRIM(CONVERT(CHAR(2),MONTH(ca.FechaDesembolso)))) = 2 THEN CONVERT(CHAR(2),MONTH(ca.FechaDesembolso)) ELSE '0'+RTRIM(CONVERT(CHAR(2),MONTH(ca.FechaDesembolso))) END AS Mes,   
       CONVERT(CHAR(4),YEAR(ca.FechaDesembolso)) +' - ' + CASE MONTH(ca.FechaDesembolso)   
       WHEN 1  THEN 'ENERO'   
       WHEN 2  THEN 'FEBRERO'   
       WHEN 3  THEN 'MARZO'   
       WHEN 4  THEN 'ABRIL'   
       WHEN 5  THEN 'MAYO'   
       WHEN 6  THEN 'JUNIO'   
       WHEN 7  THEN 'JULIO'   
       WHEN 8  THEN 'AGOSTO'   
       WHEN 9  THEN 'SEPTIEMBRE'   
       WHEN 10 THEN 'OCTUBRE'   
       WHEN 11 THEN 'NOVIEMBRE'   
       WHEN 12 THEN 'DICIEMBRE' END AS DscMes   
  INTO #CredReest       
  FROM tCsPadronCarteraDet P  
 INNER JOIN tCsCartera            ca with(nolock) ON p.CodPrestamo  = ca.CodPrestamo AND P.FechaCorte = ca.Fecha AND ca.CodUsuario = P.CodUsuario
 INNER JOIN tCsCarteraDet         cd with(nolock) ON ca.CodPrestamo = cd.CodPrestamo AND ca.Fecha     = cd.Fecha AND ca.CodUsuario = cd.CodUsuario
 --INNER JOIN tCsCarteraDet         cd with(nolock) ON P.CodPrestamo  = cd.CodPrestamo AND P.FechaCorte = cd.Fecha AND P.CodUsuario = cd.CodUsuario
  --LEFT OUTER JOIN tCsCartera      ca with(nolock) ON cd.CodPrestamo = ca.CodPrestamo AND cd.Fecha       = ca.Fecha   
 INNER JOIN tCsPadronClientes      U with(nolock) ON ca.CodUsuario  = U.CodUsuario 
 INNER JOIN tClOficinas            O with(nolock) ON ca.CodOficina  = O.CodOficina 
  LEFT OUTER JOIN tCsCarteraGrupos G with(nolock) ON ca.CodOficina  = G.CodOficina AND ca.CodGrupo = G.CodGrupo
 INNER JOIN tClMonedas  M ON ca.CodMoneda = M.CodMoneda   
 WHERE P.TipoReprog = 'REEST'  
   AND P.Desembolso >= @FechaIni  --'2012-05-01'
   AND P.Desembolso <= @FechaFin  --'2013-03-31'
   AND (P.EstadoCalculado IN ('VIGENTE', 'VENCIDO', 'CANCELADO', 'EJECUCION', 'ATRASADO', 'CASTIGADO'))   
 --ORDER BY P.Desembolso, P.CodOficina, P.codprestamo

--SELECT * FROM #CredReest WHERE Estado <> 'CANCELADO'
--select * from #CredReest WHERE Estado = 'CANCELADO'
--DROP TABLE #DetCred
SELECT Cuenta, case when PC.NumeroPlan = 0 then 'Normal' else 'Conces.' end Plann,   
       SecCuota, FechaInicio, FechaVencimiento, case when EstadoCuota = 'CANCELADO' then FechaPagoConcepto else NULL end AS FechaPago, 
       DiasAtrCuota, EstadoCuota, 0 Orden, PC.CodConcepto, DescConcepto, MontoCuota, MontoDevengado, MontoPagado, MontoCondonado, 0 Saldo   
  INTO #DetCred  
  FROM #CredReest CR
 INNER JOIN tCsPadronPlanCuotas PC ON CR.Cuenta      = PC.CodPrestamo AND CR.CodUsuario = PC.CodUsuario
 INNER JOIN tCaClConcepto       P  ON PC.CodConcepto = P.CodConcepto   
 WHERE PC.CodConcepto = 'CAPI'
   AND CR.Estado <> 'CANCELADO'
 
SELECT DISTINCT r.CodOficina, r.NomOficina, r.Fecha, r.MontoDesembolso, r.Cuenta, r.Nombre, r.Moneda, r.Estado, r.CodAnterior, r.CodSolicitud,
       r.CodProducto, r.Mes, r.DscMes, 
       SecCuota, d.FechaVencimiento, 
       CASE WHEN d.FechaPago IS NULL 
            THEN case When d.DiasAtrCuota > 0 
                      then 'Atrasada' else ' ' end ELSE 'Pagada' END AS Estatus,
       --Case When d.FechaPago IS NULL THEN ' ' ELSE 'Pagada' END AS Estatus, 
       d.FechaPago, d.DiasAtrCuota,   
       CASE WHEN d.FechaPago IS NOT NULL 
            THEN case When d.DiasAtrCuota > 0 
                      then 'Amarillo' else ' ' end END AS Color
  FROM #CredReest r  
 LEFT OUTER JOIN #DetCred d ON r.cuenta = d.cuenta  
 --WHERE d.Orden = 0  
 --and r.cuenta = '004-156-06-03-00450'
 ORDER BY r.Mes, r.NomOficina, r.Fecha ASC, r.Nombre, d.SecCuota  

--select * from #CredReest order by year(fecha), month(Fecha), codoficina, fecha, Nombre
--select * from tCsPadronPlanCuotas where codprestamo = '004-160-06-07-00108'
--select * from tCsPadronPlanCuotas where codprestamo = '004-156-06-03-00450' and codconcepto = 'CAPI'
--select * from #DetCred where cuenta = '004-156-06-03-00450'
--SELECT * FROM tCsCartera where CODPRESTAMO = '004-156-06-03-00450'
/*
select * from tCsPadronCarteraDet where codprestamo = '010-157-06-03-00065'

select * from tCsPadronPlanCuotas where codprestamo = '010-157-06-03-00065'
select * from tCsCartera where codprestamo = '010-157-06-03-00065' and fecha = '2013-03-07 00:00:00'
select * from tCsCarteraDet where codprestamo = '010-157-06-03-00065' order by fecha
select * from tCsCartera where codprestamo = '010-157-06-03-00065' order by fecha
select * from tCsPlanCuotas where codprestamo = '010-157-06-03-00065'
drop table #CredReest  
drop table #DetCred  
*/
 
/* 
 GROUP BY Cuenta, PC.NumeroPlan, SecCuota, FechaInicio, FechaVencimiento, FechaPagoConcepto, DiasAtrCuota, EstadoCuota,   
       PC.CodConcepto, DescConcepto, MontoCuota, MontoDevengado, MontoPagado, MontoCondonado
 
 select * from tCaClConcepto
   AND PC.FechaVencimiento = 
 
 SELECT codoficina, codprestamo, codusuario, sum(MontoDevengado-MontoPagado-MontoCondonado) monto  
  FROM tCsPadronPlanCuotas p  
  where p.fechavencimiento =@fecha  
 
 
--  INTO #DetCred  
  FROM (Select r.Cuenta, C.NumeroPlan, CC.SecCuota, C.FechaInicio, C.FechaVencimiento, C.FechaPago, C.DiasAtrCuota, C.EstadoCuota,   
               P.Orden, CC.CodConcepto, P.DescConcepto, sum(CC.MontoCuota) MontoCuota,  
               sum(CASE WHEN II.Descuento = 0 AND C.EstadoCuota != 'CANCELADO' THEN CC.MontoCuota ELSE CC.MontoDevengado END)   
               MontoDevengado, sum(CC.MontoPagado) MontoPagado, sum(CC.MontoCondonado) MontoCondonado,   
               sum(CASE WHEN II.Descuento = 0 AND C.EstadoCuota != 'CANCELADO' THEN CC.MontoCuota ELSE CC.MontoDevengado END - CC.MontoPagado - CC.MontoCondonado) Saldo   
          From #CredReest r  
         Inner Join tCaCuotasCli CC on r.Cuenta = CC.CodPrestamo  
         Inner Join tCaClConcepto P on CC.CodConcepto = P.CodConcepto   
         Inner Join tCaCuotas C on C.CodPrestamo = CC.CodPrestamo and C.SecCuota = CC.SecCuota and C.NumeroPlan = CC.NumeroPlan  
          Left Outer Join tCaCuotas CANT ON C.CodPrestamo  = CANT.CodPrestamo  
                                        And C.NumeroPlan   = CANT.NumeroPlan  
                                        And C.SecCuota - 1 = CANT.SecCuota  
         Inner Join tCaPrestamos PP ON PP.CodPrestamo = CC.CodPrestamo  
         Inner Join tCaProdInteres II ON II.CodProducto = PP.CodProducto  
         --Where CC.CodPrestamo = '004-160-06-07-00108'  
         Group By r.Cuenta, C.NumeroPlan, CC.SecCuota, C.FechaInicio, C.FechaVencimiento, C.FechaPago, C.DiasAtrCuota, C.EstadoCuota,P.Orden, CC.CodConcepto, P.DescConcepto   
         ) Z   
  ORDER BY 1 desc, 2, orden  



select * from tCsPadronPlanCuotas where codprestamo = '004-160-06-07-00108'
select * from tCsPlanCuotas where codprestamo = '004-160-06-07-00108'

from tCsPadronCarteraDet cd  
inner join tcscarteradet det on det.fecha=cd.fechacorte and det.codprestamo=cd.codprestamo and det.codusuario=cd.codusuario  
inner join tcscartera c on c.fecha=det.fecha and c.codprestamo=det.codprestamo  
inner join (SELECT codoficina, codprestamo, codusuario, monto from (  
SELECT codoficina, codprestamo, codusuario, sum(MontoDevengado-MontoPagado-MontoCondonado) monto  
  FROM tCsPadronPlanCuotas p  
  where p.fechavencimiento =@fecha  
  group by codoficina, codprestamo, codusuario) a  
  where monto<>0) pl  
  on pl.codoficina=cd.codoficina and pl.codprestamo=cd.codprestamo and pl.codusuario=cd.codusuario  
  inner join tcspadronclientes cl on cl.codusuario=cd.codusuario  
  left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)  
  left outer join tCsCarteraGrupos g on g.CodGrupo=cd.codgrupo and g.codoficina=cd.codoficina  
  left outer join tcspadronclientes ase on ase.codusuario=cd.ultimoasesor    



SELECT Cuenta, case when NumeroPlan = 0 then 'Normal' else 'Conces.' end Plann,   
       SecCuota, FechaInicio, FechaVencimiento, FechaPago, DiasAtrCuota, EstadoCuota, Orden,   
       CodConcepto , DescConcepto, MontoCuota, MontoDevengado, MontoPagado, MontoCondonado, Saldo   
  INTO #DetCred  
  FROM (Select r.Cuenta, C.NumeroPlan, CC.SecCuota, C.FechaInicio, C.FechaVencimiento, C.FechaPago, C.DiasAtrCuota, C.EstadoCuota,   
               P.Orden, CC.CodConcepto, P.DescConcepto, sum(CC.MontoCuota) MontoCuota,  
               sum(CASE WHEN II.Descuento = 0 AND C.EstadoCuota != 'CANCELADO' THEN CC.MontoCuota ELSE CC.MontoDevengado END)   
               MontoDevengado, sum(CC.MontoPagado) MontoPagado, sum(CC.MontoCondonado) MontoCondonado,   
               sum(CASE WHEN II.Descuento = 0 AND C.EstadoCuota != 'CANCELADO' THEN CC.MontoCuota ELSE CC.MontoDevengado END - CC.MontoPagado - CC.MontoCondonado) Saldo   
          From #CredReest r  
         Inner Join tCaCuotasCli CC on r.Cuenta = CC.CodPrestamo  
         Inner Join tCaClConcepto P on CC.CodConcepto = P.CodConcepto   
         Inner Join tCaCuotas C on C.CodPrestamo = CC.CodPrestamo and C.SecCuota = CC.SecCuota and C.NumeroPlan = CC.NumeroPlan  
          Left Outer Join tCaCuotas CANT ON C.CodPrestamo  = CANT.CodPrestamo  
                                        And C.NumeroPlan   = CANT.NumeroPlan  
                                        And C.SecCuota - 1 = CANT.SecCuota  
         Inner Join tCaPrestamos PP ON PP.CodPrestamo = CC.CodPrestamo  
         Inner Join tCaProdInteres II ON II.CodProducto = PP.CodProducto  
         --Where CC.CodPrestamo = '004-160-06-07-00108'  
         Group By r.Cuenta, C.NumeroPlan, CC.SecCuota, C.FechaInicio, C.FechaVencimiento, C.FechaPago, C.DiasAtrCuota, C.EstadoCuota,P.Orden, CC.CodConcepto, P.DescConcepto   
         ) Z   
  ORDER BY 1 desc, 2, orden  
*/
 
   
--SELECT TipoReprog,* FROM tCsPadronCarteraDet WHERE CODPRESTAMO = '071-159-06-00-00035'
--SELECT * FROM tCsCartera WHERE  CODPRESTAMO = '071-159-06-00-00035' 
--SELECT TipoReprog,eSTADOCALCULADO,* FROM tCsPadronCarteraDet WHERE CODPRESTAMO = '005-156-06-05-00397'
--SELECT TipoReprog,ESTADO,* FROM tCsCartera WHERE CODPRESTAMO = '005-156-06-05-00397'
/*
005-156-06-05-00397	LULU DE SANTA ANA
008-162-06-00-00193	GARCIA ALVAREZ ALICIA
010-302-06-06-00238	SANTANA SOLORZANO JUANA
012-162-06-07-00150	ZUÑIGA GUZMAN KARLA VIANEY
023-159-06-00-00271	GOMEZ VARELA ROSA
023-159-06-00-00272	FERNANDEZ HERNANDEZ OSCAR
*/  
  
GO