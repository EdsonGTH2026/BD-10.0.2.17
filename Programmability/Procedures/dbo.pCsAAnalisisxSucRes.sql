SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--DROP PROC pCsAAnalisisxSucF
--EXEC pCsAAnalisisxSucF '20140312',''
CREATE PROCEDURE [dbo].[pCsAAnalisisxSucRes]
                 ( @Fecha      SMALLDATETIME ,
                   @CodOficina VARCHAR(300)  )
  AS
--DECLARE @Fecha SMALLDATETIME
--    SET @Fecha = '20140312'
    
DECLARE @FechaIni SMALLDATETIME    
DECLARE @Periodo1 VARCHAR(6)      
DECLARE @FechaSig SMALLDATETIME    

    SET @Periodo1 = dbo.fduFechaATexto(@Fecha, 'AAAAMM')      
    SET @FechaIni = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))    
    print @FechaIni

set @FechaSig = @FechaIni

--Crea Tabla Temporales
CREATE TABLE #CarteraVig(CodOficina CHAR(5), SaldoCarteraVigente NUMERIC(16,2))
CREATE TABLE #EstimRec(CodOficina CHAR(5), MontoCuota NUMERIC(16,2))
CREATE TABLE #PagosDia(CodOficina CHAR(5), TotalPagosDia NUMERIC(16,2))
CREATE TABLE #DesemCancel(CodOficina CHAR(5), DesembolsoCancelados NUMERIC(16,2))
CREATE TABLE #Desembolsos(CodOficina CHAR(5), TotalMontoDesembolso NUMERIC(16,2))
CREATE TABLE #ResumenSuc(Fecha SMALLDATETIME, CodOficina CHAR(50), SaldoCarteraVigente NUMERIC(16,2), MontoCuota NUMERIC(16,2),
		TotalPagosDia NUMERIC(16,2), DesembolsoCancelados NUMERIC(16,2), TotalMontoDesembolso NUMERIC(16,2))

WHILE @FechaSig <= @Fecha
   BEGIN
    
--1. Saldo de Cartera Vigente 
--CREATE TABLE #CarteraVig(CodOficina CHAR(5), SaldoCarteraVigente NUMERIC(16,2))
INSERT INTO #CarteraVig
SELECT c.CodOficina,
       sum(cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) SaldoCarteraVigente
  FROM tCsCartera c WITH(NOLOCK)  
 INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo=cd.codprestamo  
 WHERE c.cartera IN ('ACTIVA')  
   AND c.Fecha = @FechaSig		--@Fecha
 GROUP BY c.CodOficina
     
--2.	Estimación de Recuperación (Pagos)- Son los pagos que se tienen programados para el día siguiente, durante el mes por día. solo para créditos vigentes? Sí, Para todos los créditos? Es decir que este programado su 2do pago o posteriores. Así es
--CREATE TABLE #EstimRec(CodOficina CHAR(5), MontoCuota NUMERIC(16,2))
INSERT INTO #EstimRec
SELECT CodOficina,  --CuotasVenc.FechaVencimiento, 
       CuotasVenc.CAPI+CuotasVenc.INTE+CuotasVenc.INPE MontoCuota 
  FROM (Select CodOficina, --Fecha, CodPrestamo, FechaVencimiento, 
               SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE 
		 From (select p.CodOficina, p.Fecha, p.FechaVencimiento, p.CodPrestamo,  
	  			      case CodConcepto when 'capi' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as CAPI, 
					  case CodConcepto when 'inte' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as INTE, 
				      case CodConcepto when 'inpe' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as INPE, 
					  case CodConcepto when 'inve' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as INVE
				 from tCsPadronPlanCuotas p WITH(NOLOCK) 
			    inner join tCsCartera     c WITH(NOLOCK) ON p.codprestamo = c.codprestamo and c.cartera IN ('ACTIVA') and p.FechaVencimiento = c.Fecha 
			    where EstadoCuota <> 'cancelado'
  		        --and c.cartera = 'ACTIVA'
			      and p.FechaVencimiento >= @FechaIni and p.FechaVencimiento <= @FechaSig		--@Fecha
			  ) A 
		 Group By CodOficina--, fecha, codprestamo, fechavencimiento
      ) CuotasVenc

--3.	Recuperación Ejecutada - Son todos los pagos recibidos en el día, solo para créditos vigentes? Sí Para todos los créditos? Es decir que este programado su 2do pago o posteriores. Solo lo recuperado real
-- CREATE TABLE #PagosDia(CodOficina CHAR(5), TotalPagosDia NUMERIC(16,2))
 INSERT INTO #PagosDia
 SELECT t.codoficina, sum(MontoTotalTran) TotalPagosDia
   FROM tCsTransaccionDiaria t WITH(NOLOCK) 
  INNER JOIN tCsCartera      c WITH(NOLOCK) ON c.codprestamo = t.codigocuenta  AND c.fecha = t.fecha 
  WHERE t.Fecha  = @FechaSig		--@Fecha
    AND (t.descripciontran NOT LIKE 'CONDONACIONES%'  AND t.descripciontran NOT LIKE 'desembolso%')
    AND t.codsistema = 'CA' 
  GROUP BY t.codoficina
           
--4.Estimación de Desembolso - En esta parte tengo la pregunta de en base a que requieres la estimación?  Es en base a los cancelados? Con cuantos días de atraso al cancelar su crédito?. En la proyección por Asesor ( Renovaciones, tanto de las canceladas en el mes como en el histórico posible de clientes inactivos. +Meta mensual de la sucursal)
--CREATE TABLE #DesemCancel(CodOficina CHAR(5), DesembolsoCancelados NUMERIC(16,2))
INSERT INTO #DesemCancel
SELECT cd.codoficina, SUM(Monto) DesembolsoCancelados
  FROM tCsPadronCarteraDet cd WITH(NOLOCK) 
 WHERE EstadoCalculado = 'cancelado' 
   AND Cancelacion >= @FechaIni AND Cancelacion <= @FechaSig		--@Fecha
 GROUP BY cd.codoficina

--5.Desembolso Ejecutado - Desembolsos de día. Sí
--CREATE TABLE #Desembolsos(CodOficina CHAR(5), TotalMontoDesembolso NUMERIC(16,2))
INSERT INTO #Desembolsos
 SELECT cd.codoficina, sum(cd.MontoDesembolso) TotalMontoDesembolso
   FROM tCsCartera c  WITH(NOLOCK) 
  INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo = cd.codprestamo  
  WHERE c.Fecha >= @FechaIni AND c.Fecha <= @FechaSig		--@Fecha
    AND c.FechaDesembolso = @FechaSig		--@Fecha
  GROUP BY cd.codoficina

--ANALISIS FINAL X OFICINA
INSERT INTO #ResumenSuc
SELECT @FechaSig Fecha, ca.CodOficina+' '+o.NomOficina Oficina,
       isnull(ca.SaldoCarteraVigente,0)  CarteraVigente,
       isnull(er.MontoCuota,0)           EstimacionRecuperacion,
       isnull(pa.TotalPagosDia,0)        RecuperacionEjecutada,
       isnull(dc.DesembolsoCancelados,0) EstimacionDesembolso,
       isnull(de.TotalMontoDesembolso,0) DesembolsoEjecutado
  FROM #CarteraVig ca 
 INNER JOIN tClOficinas    o WITH(NOLOCK) ON ca.CodOficina = o.CodOficina
  LEFT OUTER JOIN #DesemCancel dc ON dc.codoficina = ca.codoficina
  LEFT OUTER JOIN #Desembolsos de ON de.codoficina = ca.codoficina
  LEFT OUTER JOIN #PagosDia    pa ON pa.codoficina = ca.codoficina
  LEFT OUTER JOIN #EstimRec    er ON er.codoficina = ca.codoficina
 WHERE o.Tipo <> 'cerrada'
 GROUP BY ca.CodOficina, o.NomOficina, SaldoCarteraVigente, MontoCuota, TotalPagosDia, DesembolsoCancelados, TotalMontoDesembolso
 ORDER BY convert(integer,ca.CodOficina), o.NomOficina


delete from #CarteraVig
delete from #DesemCancel  
delete from #Desembolsos
delete from #PagosDia
delete from #EstimRec


	set @fechaSig = DATEADD(dd, 1, @FechaSig) 


END

select * from #ResumenSuc  order by fecha


drop table #CarteraVig
drop table #DesemCancel  
drop table #Desembolsos
drop table #PagosDia
drop table #EstimRec
drop table #ResumenSuc




GO