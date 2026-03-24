SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext 'BI_PagosSemanales'

Create procedure [dbo].[BI_PagosSemanales] as  
DECLARE @fecha smalldatetime;  
SELECT @fecha =fechaconsolidacion FROM vcsfechaconsolidacion;  
  
DECLARE @fechaIni smalldatetime;  
--SELECT @fechaIni ='20250803'    
-- Calcular el domingo de la semana actual y esa es la Fecha inicial  
SET @fechaIni = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @fecha), CAST(@fecha AS DATE));  
  
DECLARE @fechafin smalldatetime;  
-- calcular el siguiente domingo  
SET @fechafin = DATEADD(  
    DAY,  
    (8 - DATEPART(WEEKDAY, @fecha)) % 7 +   
    CASE WHEN DATEPART(WEEKDAY, @fecha) = 1 THEN 7 ELSE 0 END,  
    @fecha  
);  
  
SELECT   
p.CodPrestamo, Region,   
CASE WHEN Promotor in ('VILLANUEVA RAMIREZ PEDRO') THEN 'VICTORIA'   
  WHEN Promotor in ('TADEO RICO EDGAR GUSTAVO','MARQUEZ LEON RENE YAMANI','CERON VIDAL ROBERTO EMMANUEL','MOJICA RUIZ JOSE ALBERTO') THEN 'CARLOS A. CARRILLO'  
  WHEN p.Sucursal = 'TIERRA COLORADA' THEN 'SAN MARCOS'  
  WHEN p.Sucursal = 'Tecamac' THEN 'PIRAMIDES'  
  ELSE p.Sucursal END Sucursal,   
case when p.Region in ('Costa Chica','Costa Grande','Centro','Estado') then 'Centro'  
      when p.Region in ('Sur tizimin','Sur progreso') then 'Sur'  
   when p.Region in ('Tabasco - Chiapas','Veracruz Norte','Veracruz Sur') then 'Veracruz'  
   when p.Region in ('Bajio Norte','Bajio Occidente','Jalisco') then 'Bajio'  
   else p.Region end Division,  
NroDiasAtraso_Ini AS NroDiasAtraso,FechaConsulta_Ini AS FechaIni, FechaActualiza AS FechaConsulta, p.FechaVencimiento,p.DIA_DE_PAGO AS DiaPago,NombreCompleto AS Cliente, Ciclo,Telefono,  
PagoAdelantado_Ini AS PagoAdelantado,  
PagoActual_Segui-PagoAdelantado_Ini AS Pago,  
MontoCuota_Ini AS MontoCuota,  
DeudaCuotaLejana_Ini AS DeudaCuotaLejana,  
DeudaSemanaActual_Ini AS DeudaSemanaActual,  
DevengadoSemana_Ini AS DevengadoSemana,  
REPLACE(Promotor,'VCITLALLY', 'CITLALLY') Promotor,  
EstatusActual_Segui,  
CubetaMora_Ini AS Cubeta,  
  
CASE   
   WHEN NroDiasAtraso_Segui IS NULL THEN 0   
   ELSE NroDiasAtraso_Segui   
END NroDiasAtraso_Segui,  
CASE   
    WHEN NroDiasAtraso_Segui IS NOT NULL AND NroDiasAtraso_Segui >= 1 THEN cl.SaldoPonerCorriente  
    ELSE PagoRequeridoDinamico_Segui  
END AS PagoRequerido,  
SecCuota,  
SaldoCapital_Ini AS SaldoCapIni  
into #ptmosSemana  
FROM FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor p   
LEFT OUTER JOIN tCsADatosCliCarteraActiva cl on cl.Codprestamo=p.CodPrestamo  
WHERE FechaActualiza=@fecha  
  
--SELECT * FROM #ptmosSemana  
  
  
  
  
  
--SELECT *  
----into #ptmosSemana  
--FROM FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor p WHERE FechaActualiza=@fecha  
  
  
SELECT   
    CodigoCuenta AS CodPrestamo,  
    DATEADD(DAY, 1 - DATEPART(WEEKDAY, Fecha), CAST(Fecha AS DATE)) AS SemanaInicio,  
    SUM(MontoTotalTran) AS PagadoSemana  
INTO #PagosPorSemana  
FROM tCsTransaccionDiaria WITH (NOLOCK)  
WHERE CodigoCuenta IN  (select codprestamo from #ptmosSemana)   
    AND MontoTotalTran > 0  
    AND DescripcionTran NOT LIKE 'Desembolso%'  
    AND DescripcionTran NOT LIKE 'PagoGarantia%'    
    AND extornado=0 and codsistema='CA' and tipotransacnivel3 in(104,105,2)  
GROUP BY CodigoCuenta, DATEADD(DAY, 1 - DATEPART(WEEKDAY, Fecha), CAST(Fecha AS DATE))  
  
  
--devengado por semana  
SELECT   
    CodPrestamo,  
    DATEADD(DAY, 1 - DATEPART(WEEKDAY, FechaVencimiento), CAST(FechaVencimiento AS DATE)) AS SemanaInicio,  
    SUM(MontoDevengado) AS DevengadoSemana  
INTO #DevengadoPorSemana  
FROM tcspadronplancuotas WITH (NOLOCK)   
    WHERE CodPrestamo in (select codprestamo from #ptmosSemana)        
GROUP BY CodPrestamo, DATEADD(DAY, 1 - DATEPART(WEEKDAY, FechaVencimiento), CAST(FechaVencimiento AS DATE))  
  
  
--pagos y devengado  
  
SELECT   
    COALESCE(CAST(p.CodPrestamo AS VARCHAR(19)), CAST(d.CodPrestamo AS VARCHAR(19))) AS CodPrestamo,  
    COALESCE(p.SemanaInicio, d.SemanaInicio) AS SemanaInicio,  
    ISNULL(d.DevengadoSemana, 0) AS DevengadoSemana,  
    ISNULL(p.PagadoSemana, 0) AS PagadoSemana  
INTO #PagosVsDevengado  
FROM #PagosPorSemana p  
FULL OUTER JOIN #DevengadoPorSemana d  
ON p.CodPrestamo = d.CodPrestamo AND p.SemanaInicio = d.SemanaInicio  
  
  
-- calcula rezago   
SELECT   
    actual.CodPrestamo,  
    actual.SemanaInicio,  
    actual.DevengadoSemana,  
    actual.PagadoSemana,  
    ISNULL(acum.RezagoAcumulado, 0) AS RezagoAcumulado,  
    ISNULL(prev.RezagoPrevio, 0) AS RezagoPrevio,  
  
    -- Estatus: si está en LIQUIDADOS, entonces 'LIQUIDADO'  
    CASE   
        WHEN liq.CodPrestamo IS NOT NULL and liq.Estado = 'Sin Renovar' THEN 'LIQUIDADO'  
        --WHEN p.NroDiasAtraso_Segui >= 1 THEN 'VENCIDO'  
        WHEN ISNULL(acum.RezagoAcumulado, 0) <= 0 THEN 'CORRIENTE'  
        ELSE 'ATRASADO'  
    END AS Estatus,  
  
    -- PagoParaPonerAlCorriente: si está en LIQUIDADOS, poner 0  
    CASE   
        WHEN liq.CodPrestamo IS NOT NULL and liq.Estado = 'Sin Renovar' THEN 0  
        --WHEN p.NroDiasAtraso_Segui IS NOT NULL AND p.NroDiasAtraso_Segui >= 1 THEN a.SaldoPonerCorriente  
        WHEN ISNULL(acum.RezagoAcumulado, 0) <= 0 THEN 0  
        ELSE actual.DevengadoSemana + ISNULL(prev.RezagoPrevio, 0) - PagadoSemana  
    END AS PagoParaPonerAlCorriente,  
    ISNULL(a.NroDiasAtraso, 0) AS NroDiasAtrasoActual  
INTO #Final_ConDatosSemana  
FROM #PagosVsDevengado actual  
OUTER APPLY (  
    SELECT SUM(DevengadoSemana - PagadoSemana) AS RezagoAcumulado  
    FROM #PagosVsDevengado h  
    WHERE h.CodPrestamo = actual.CodPrestamo AND h.SemanaInicio <= actual.SemanaInicio) acum  
OUTER APPLY (  
    SELECT SUM(DevengadoSemana - PagadoSemana) AS RezagoPrevio  
    FROM #PagosVsDevengado h  
    WHERE h.CodPrestamo = actual.CodPrestamo AND h.SemanaInicio < actual.SemanaInicio) prev  
LEFT OUTER JOIN #ptmosSemana p ON p.CodPrestamo = actual.CodPrestamo  
LEFT OUTER JOIN tCsACaLIQUI_RR liq ON liq.CodPrestamo = actual.CodPrestamo  -- Verifica si está liquidado  
LEFT OUTER JOIN tCsADatosCliCarteraActiva a ON a.CodPrestamo = actual.CodPrestamo  
WHERE actual.SemanaInicio = @fechaIni  -- Filtra solo la semana actual  
ORDER BY actual.CodPrestamo;  
  
  
  
  
-- Obtener los préstamos que no tienen datos de la semana actual  
SELECT   
    p.CodPrestamo,  
    @fechaIni AS SemanaInicio,  
    0 AS DevengadoSemana,  
    0 AS PagadoSemana,  
    NULL AS RezagoAcumulado,  
    NULL AS RezagoPrevio,  
    -- Estatus: LIQUIDADO si cumple condición, si no VENCIDO  
    CASE   
        WHEN a.SaldoPonerCorriente IS NULL AND liq.CodPrestamo IS NOT NULL THEN 'LIQUIDADO'  
        ELSE 'VENCIDO'  
    END AS Estatus,  
    -- PagoParaPonerAlCorriente: 0 si es liquidado, si no el valor original  
    CASE   
        WHEN a.SaldoPonerCorriente IS NULL AND liq.CodPrestamo IS NOT NULL THEN 0  
        ELSE a.SaldoPonerCorriente  
    END AS PagoParaPonerAlCorriente,  
    ISNULL(p.NroDiasAtraso_Segui, 0) AS NroDiasAtrasoActual  
INTO #Final_SinDatosSemana  
FROM #ptmosSemana p  
LEFT OUTER JOIN #Final_ConDatosSemana f ON p.CodPrestamo = f.CodPrestamo  
LEFT OUTER JOIN tCsADatosCliCarteraActiva a ON p.CodPrestamo = a.CodPrestamo  
LEFT OUTER JOIN tCsACaLIQUI_RR liq ON p.CodPrestamo = liq.CodPrestamo  
WHERE f.CodPrestamo IS NULL  
  
  
  
  
  
  
-- Unir todo  
--SELECT *  
--FROM #Final_ConDatosSemana  
--UNION ALL  
--SELECT *  
--FROM #Final_SinDatosSemana  
  
  
SELECT *  
INTO #PagoCorriente  
FROM (  
    SELECT *  
    FROM #Final_ConDatosSemana  
    UNION ALL  
    SELECT *  
    FROM #Final_SinDatosSemana  
) AS UnionFinal;  
  
--SELECT * FROM #PagoCorriente  
  
  
SELECT   
    p.CodPrestamo, p.Region,   
    p.Sucursal,   
    p.Division,  
    p.NroDiasAtraso,p.FechaIni, p.FechaConsulta, p.FechaVencimiento,p.DiaPago,  
    p.Promotor,  
    p.Cliente, p.Ciclo,p.Telefono,  
    p.PagoAdelantado,  
    p.Pago,  
    p.MontoCuota,  
    p.DeudaCuotaLejana,  
    p.DeudaSemanaActual,  
    p.DevengadoSemana,  
    p.PagoAdelantado+p.Pago AS Pagado,  
    --p.Estatus,  
    p.Cubeta,  
    --p.NroDiasAtraso_Segui,  
    p.PagoRequerido,  
    p.SecCuota,  
    p.SaldoCapIni,  
    c.PagoParaPonerAlCorriente,  
    c.NroDiasAtrasoActual,  
    CASE  
        WHEN p.PagoAdelantado+p.Pago = 0 THEN 'Sin Pago'                       
    WHEN c.PagoParaPonerAlCorriente = 0 THEN 'Pagado'       
        WHEN c.PagoParaPonerAlCorriente > 0 THEN 'Pago Parcial'   
        ELSE 'Sin Pago'                                           
    END AS Estatus,  
    CASE  
        WHEN p.PagoAdelantado+p.Pago >= p.PagoRequerido THEN 'Completo'                       
        ELSE 'Incompleto'                                           
    END AS PagoSemanal  
INTO #ResultadoFinal  
FROM #ptmosSemana p  
INNER JOIN #PagoCorriente c  
    ON p.CodPrestamo = c.CodPrestamo;  
  
select * from #ResultadoFinal  
  
  
  
-- Limpieza  
DROP TABLE #PagosPorSemana                 
DROP TABLE #DevengadoPorSemana                
DROP TABLE #PagosVsDevengado                
DROP TABLE #Final_ConDatosSemana  
DROP TABLE #Final_SinDatosSemana  
DROP TABLE #ptmosSemana  
DROP TABLE #PagoCorriente  
DROP TABLE #ResultadoFinal
GO