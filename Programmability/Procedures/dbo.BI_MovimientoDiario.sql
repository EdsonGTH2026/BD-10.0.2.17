SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext 'BI_MovimientoDiario'
CREATE procedure [dbo].[BI_MovimientoDiario] as  
DECLARE @fechafin SMALLDATETIME;  
SELECT @fechafin = fechaconsolidacion FROM vcsfechaconsolidacion;  
  
DECLARE @fechacorte SMALLDATETIME;  
SET @fechacorte = DATEADD(MONTH, -3, DATEADD(DAY, DAY(@fechafin) * -1 + 1, @fechafin));  
  
-- Crea tabla de castigados (solo una vez)  
SELECT c.CodPrestamo,  
       DATEADD(DAY, DAY(c.FechaCastigo)*-1+1, c.FechaCastigo) AS Fecha  
INTO #Castigados  
FROM tCsCartera c WITH (NOLOCK)  
WHERE c.codoficina NOT IN ('97','98','231','230','999')  
  AND c.Fecha = c.FechaCastigo  
  AND c.FechaCastigo BETWEEN '20250101' AND @fechafin  
  AND DAY(c.FechaCastigo) IN (28,29,30,31)  
  AND MONTH(c.FechaCastigo) IN (3,6,9,12)  
  AND c.codprestamo NOT IN (  
      SELECT codprestamo FROM tCsCarteraAlta WITH (NOLOCK)  
  );  
  
CREATE TABLE #Consolidado (  
    fecha               SMALLDATETIME,  
    Division            VARCHAR(59),  
    region              VARCHAR(50),  
    sucursal            VARCHAR(50),  
    CarteraVigInicial   MONEY,  
    CapitalVigCobrado   MONEY,  
    MontoColocado       MONEY,  
    PasoVencida         MONEY,  
    CarteraVenInicial   MONEY,  
    CapitalVenCobrado   MONEY,  
    RegresoVigente      MONEY,  
    WA                  MONEY,  
    Anticipado          MONEY,  
    Nuevo               MONEY,  
    Reactivado          MONEY,  
    Renovado            MONEY,  
    Castigo             MONEY -- nueva columna  
);  
  
WHILE @fechacorte <= @fechafin  
BEGIN  
  
    SELECT c.CodPrestamo,  
           CASE   
               WHEN z.nombre IN ('Bajio Norte','Bajio Occidente') THEN 'Bajio'  
               WHEN z.nombre IN ('Jalisco') THEN 'Bajio'  
               WHEN z.nombre IN ('Centro','Estado','Costa Grande','Costa Chica') THEN 'Centro'  
               WHEN z.nombre IN ('Sur progreso','Sur tizimin') THEN 'Sur'  
               WHEN z.nombre IN ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') THEN 'Veracruz'  
               ELSE 'NA'   
           END AS Division,  
           z.Nombre AS region,  
           o.NomOficina AS sucursal,  
           c.NroDiasAtraso,  
           c.SaldoCapital  
    INTO #previa  
    FROM tcscartera c WITH (NOLOCK)  
    INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = c.codoficina  
    INNER JOIN tclzona z ON z.zona = o.zona  
    WHERE c.Fecha = @fechacorte - 1  
      AND c.codoficina NOT IN ('97','231','230','98','999')   
      AND c.cartera = 'ACTIVA'  
      AND c.codprestamo NOT IN (  
          SELECT codprestamo FROM tCsCarteraAlta WITH (NOLOCK)  
      );  
  
    SELECT c.CodPrestamo,  
           CASE   
               WHEN z.nombre IN ('Bajio Norte','Bajio Occidente') THEN 'Bajio'  
               WHEN z.nombre IN ('Jalisco') THEN 'Bajio'  
               WHEN z.nombre IN ('Centro','Estado','Costa Grande','Costa Chica') THEN 'Centro'  
               WHEN z.nombre IN ('Sur progreso','Sur tizimin') THEN 'Sur'  
               WHEN z.nombre IN ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') THEN 'Veracruz'  
               ELSE 'NA'   
           END AS Division,  
           z.Nombre AS region,  
           o.NomOficina AS sucursal,  
           c.NroDiasAtraso,  
           c.SaldoCapital,  
           ISNULL(v.NroDiasAtraso, 0) AS AtrasoAnt,  
           ISNULL(v.SaldoCapital, 0) AS SaldoAnt,  
           CASE   
               WHEN v.NroDiasAtraso IS NULL THEN 'nuevo'   
               WHEN c.NroDiasAtraso >= 31 AND v.NroDiasAtraso <= 30 THEN 'rollforward'  
               WHEN c.NroDiasAtraso <= 30 AND v.NroDiasAtraso >= 31 THEN 'rollback'  
               ELSE 'sin movimiento'   
           END AS TipoMovimiento,  
           CASE   
               WHEN v.NroDiasAtraso IS NOT NULL THEN 'NA'   
               WHEN c.CodPrestamo IN (SELECT CodPrestamo FROM FNMGConsolidado.dbo.tCaDesembAutoRenovacion) THEN 'Anticipado WA'  
               WHEN p.TipoReprog = 'RENOV' THEN 'Anticipado'   
               WHEN p.SecuenciaCliente = 1 THEN 'Nuevo'  
               WHEN DATEDIFF(MM, t.cancelacion, p.desembolso) >= 1 THEN 'Reactivado'   
    WHEN t.cancelacion IS NULL AND p.SecuenciaCliente > 1 THEN 'Reactivado'  
               ELSE t.estado   
           END AS TipoColocado  
    INTO #final  
    FROM tcscartera c WITH (NOLOCK)  
    INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = c.codoficina  
    INNER JOIN tclzona z ON z.zona = o.zona  
    LEFT JOIN #previa v WITH (NOLOCK) ON v.CodPrestamo = c.CodPrestamo  
    LEFT JOIN tcspadroncarteradet p WITH (NOLOCK) ON p.CodPrestamo = c.CodPrestamo  
    LEFT JOIN tCsACaLIQUI_RR t ON t.codprestamonuevo = p.CodPrestamo  
    WHERE c.Fecha = @fechacorte  
      AND c.codoficina NOT IN ('97','231','230','98','999')   
      AND c.cartera = 'ACTIVA'  
      AND c.codprestamo NOT IN (  
          SELECT codprestamo FROM tCsCarteraAlta WITH (NOLOCK)  
      );  
  
    SELECT CodPrestamo,  
           Division,  
           region,  
           sucursal,  
           0 AS NroDiasAtraso,  
           0 AS SaldoCapital,  
           NroDiasAtraso AS AtrasoAnt,  
           SaldoCapital AS SaldoAnt,  
           CASE   
               WHEN NroDiasAtraso >= 31 THEN 'LiqVencida'  
               WHEN NroDiasAtraso <= 30 THEN 'LiqVigente'  
               ELSE 'sin movimiento'   
           END AS TipoMovimiento,  
           'Liquidado' AS TipoColocado  
    INTO #Liq  
    FROM #previa p  
    WHERE p.CodPrestamo NOT IN (SELECT CodPrestamo FROM #final);  
  
    CREATE TABLE #Union (  
        CodPrestamo VARCHAR(50),  
        Division VARCHAR(100),  
        region VARCHAR(100),  
        sucursal VARCHAR(100),  
        NroDiasAtraso INT,  
        SaldoCapital MONEY,  
        AtrasoAnt INT,  
        SaldoAnt MONEY,  
        TipoMovimiento VARCHAR(100),  
        TipoColocado VARCHAR(100)  
    );  
  
    INSERT INTO #Union  
    SELECT * FROM #final  
    UNION ALL  
    SELECT * FROM #Liq;  
  
    INSERT INTO #Consolidado  
    SELECT   
        @fechacorte AS fecha,  
        Division,  
        region,  
        sucursal,  
        SUM(CASE WHEN AtrasoAnt <= 30 THEN SaldoAnt ELSE 0 END) AS CarteraVigInicial,  
        SUM(CASE WHEN AtrasoAnt <= 30 AND TipoMovimiento <> 'nuevo' THEN SaldoAnt - SaldoCapital ELSE 0 END) AS CapitalVigCobrado,  
        SUM(CASE WHEN TipoMovimiento = 'nuevo' THEN SaldoCapital ELSE 0 END) AS MontoColocado,  
        SUM(CASE WHEN TipoMovimiento = 'rollforward' THEN SaldoAnt ELSE 0 END) AS PasoVencida,  
        SUM(CASE WHEN AtrasoAnt > 30 THEN SaldoAnt ELSE 0 END) AS CarteraVenInicial,  
        SUM(CASE WHEN AtrasoAnt > 30 THEN SaldoAnt - SaldoCapital ELSE 0 END) AS CapitalVenCobrado,  
        SUM(CASE WHEN TipoMovimiento = 'rollback' THEN SaldoCapital ELSE 0 END) AS RegresoVigente,  
        SUM(CASE WHEN TipoColocado = 'Anticipado WA' THEN SaldoCapital ELSE 0 END) AS WA,  
        SUM(CASE WHEN TipoColocado = 'Anticipado' THEN SaldoCapital ELSE 0 END) AS Anticipado,  
        SUM(CASE WHEN TipoColocado = 'Nuevo' THEN SaldoCapital ELSE 0 END) AS Nuevo,  
        SUM(CASE WHEN TipoColocado = 'Reactivado' THEN SaldoCapital ELSE 0 END) AS Reactivado,  
        SUM(CASE WHEN TipoColocado = 'Renovado' THEN SaldoCapital ELSE 0 END) AS Renovado,  
        SUM(CASE WHEN c.CodPrestamo IS NOT NULL THEN SaldoCapital ELSE 0 END) AS Castigo  
    FROM #Union u  
    LEFT JOIN #Castigados c ON c.CodPrestamo = u.CodPrestamo AND c.Fecha = @fechacorte  
    GROUP BY Division, region, sucursal  
    ORDER BY Division, region, sucursal;  
  
    DROP TABLE #previa;  
    DROP TABLE #Liq;  
    DROP TABLE #final;  
    DROP TABLE #Union;  
  
    SET @fechacorte = DATEADD(DAY, 1, @fechacorte);  
END  
  
SELECT * FROM #Consolidado;  
  
DROP TABLE #Consolidado;  
DROP TABLE #Castigados;  
GO