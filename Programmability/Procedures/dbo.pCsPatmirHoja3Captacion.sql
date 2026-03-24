SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsPatmirHoja3Captacion
--EXEC pCsPatmirHoja3Captacion '20140201', '20140228'
CREATE PROCEDURE [dbo].[pCsPatmirHoja3Captacion]
               ( @FecIni SMALLDATETIME ,
                 @FecFin SMALLDATETIME )
AS                 
--DECLARE @fecini SMALLDATETIME
--DECLARE @fecfin SMALLDATETIME
--SET @fecini='20130901'
--SET @fecfin='20130930'

--HOJA CAPTACIÓN
SELECT DISTINCT ''''+'0468' AS FolioIF,
       ah.codusuario AS CveSocCte,
       ''''+ah.codcuenta AS Cuenta,
       ah.codoficina  AS Sucursal,
	   replicate('0',2-len(cast(day(ah.Fechaapertura)as varchar(2)))) + cast(day(ah.Fechaapertura) as varchar(2)) +'/'+replicate('0',2-len(cast(month(ah.Fechaapertura)as varchar(2)))) + cast(month(ah.Fechaapertura) as varchar(2)) +'/'+cast(year(ah.Fechaapertura)as char(4)) FechaApertura,
       --cast(year(ah.Fechaapertura)as char(4)) +'/'+ replicate('0',2-len(cast(month(ah.Fechaapertura)as varchar(2)))) + cast(month(ah.Fechaapertura) as varchar(2))+'/'+ replicate('0',2-len(cast(day(ah.Fechaapertura)as varchar(2)))) + cast(day(ah.Fechaapertura) as varchar(2)) FechaApertura,
       case when pa.idTipoProd=1 then 'A LA VISTA' ELSE 'A PLAZO' END TipoCta,
	   replicate('0',2-len(cast(day(ah.FechaUltMov)as varchar(2)))) + cast(day(ah.FechaUltMov) as varchar(2)) +'/'+replicate('0',2-len(cast(month(ah.FechaUltMov)as varchar(2)))) + cast(month(ah.FechaUltMov) as varchar(2)) +'/'+cast(year(ah.FechaUltMov)as char(4)) FechaUltDep,
       --cast(year(ah.FechaUltMov)as char(4)) +'/'+ replicate('0',2-len(cast(month(ah.FechaUltMov)as varchar(2)))) + cast(month(ah.FechaUltMov) as varchar(2))+'/'+ replicate('0',2-len(cast(day(ah.FechaUltMov)as varchar(2)))) + cast(day(ah.FechaUltMov) as varchar(2)) FechaUltDep,
       case when ah.fechavencimiento is null then 'A LA VISTA' else replicate('0',2-len(cast(day(ah.fechavencimiento)as varchar(2)))) + cast(day(ah.fechavencimiento) as varchar(2)) +'/'+replicate('0',2-len(cast(month(ah.fechavencimiento)as varchar(2)))) + cast(month(ah.fechavencimiento) as varchar(2)) +'/'+cast(year(ah.fechavencimiento)as char(4)) end FechaVencimiento,
       --case when pa.idTipoProd=1 then 'A LA VISTA' ELSE isnull(ah.fechavencimiento,'NA') END FechaVencimiento,
       case when pa.idTipoProd=1 then 1  else isnull(ah.Plazo,0) end AS PlazoDep,
       case when pa.idTipoProd=1 then 30 else isnull(ah.Plazo,0) end AS FormaPagoRendmtoDias, 
       --isnull(ti.NroDias,0) AS FormaPagoRendmtoDias, 
       CONVERT(NUMERIC(16,1),ah.TasaInteres) as TasaIntNominalPactadaAnual,
       --ah.saldocuenta saldocuenta,ah.fecha,
       isnull(ah.saldocuenta,0) AS MtoAhorroDepPlazoCapital, 
       --isnull(c.saldocta,0) AS MtoAhorroDepPlazoCapital, 
       --case when pa.idTipoProd=1 then '' else cast(ah.saldocuenta as varchar(20)) end AS MtoAhorroDepPlazoCapital, 
       case when pa.idTipoProd=1 then 0 else isnull(ah.intacumulado,0) end AS IntDevengNoPagAlCierreMesDepAPlazoAcum,
       isnull(ah.saldocuenta,0) + (case when pa.idTipoProd=1 then 0 else isnull(ah.intacumulado,0) end) AS SaldoTotalAlCierre_IntDevengNoPagAlCierreMesDepAPlazoAcum
       --isnull(c.saldocta,0)+(case when pa.idTipoProd=1 then 0 else isnull(ah.intacumulado,0) end) AS SaldoTotalAlCierre_IntDevengNoPagAlCierreMesDepAPlazoAcum
  into #Hoja3      
  FROM tcsahorros ah with(nolock) 
 /*INNER JOIN (Select ultimodia From tclperiodo with(nolock)
             Where ultimodia>=@FecIni) p ON ah.fecha = p.ultimodia*/
 --INNER JOIN #clientes c on c.codusuario=ah.codusuario AND c.codcuenta=ah.codcuenta
 INNER JOIN tAhProductos pa with(nolock) ON pa.idproducto=ah.codproducto
 LEFT OUTER JOIN tAhClTipoInteres ti with(nolock) ON ah.CodTipoInteres = ti.CodTipoInteres --and ah.idTipoProd = ti.idTipoProd
 --INNER JOIN tcspadronahorros cl with(nolock) ON cl.codusuario=ah.codusuario
 --INNER JOIN tcspadronclientes cl with(nolock) ON cl.codusuario=ah.codusuario
-- INNER JOIN tcloficinas o with(nolock) ON o.codoficina=cl.codoficina
WHERE ah.fecha = @FecFin --'20130831' --398
  AND ah.codusuario IN (Select CodUsuario From tCsFondReportados Where CodFondo = 'PT') --(select cvesociocte from #hoja11) 
  
SELECT * FROM #Hoja3

DROP TABLE #HOJA3
GO