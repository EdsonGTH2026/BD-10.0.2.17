SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sp_helptext pCsAhEstadoCuenta

--[dbo].[pCsAhEstadoCuenta] @Usuario VARCHAR(20), @Cuenta VARCHAR(25),@fraccioncta varchar(3),@renovado int, @PrimerCorte2 SMALLDATETIME, @UltimoCorte2 SMALLDATETIME  
CREATE PROCEDURE [dbo].[pCsAhEstadoCuentaQA] @Usuario VARCHAR(20), @Cuenta VARCHAR(25),@fraccioncta varchar(3),@renovado int, @PrimerCorte SMALLDATETIME, @UltimoCorte SMALLDATETIME  
AS  
  
--declare @Usuario  Varchar(50)  
--declare @Cuenta   Varchar(25)  
--declare @fraccioncta varchar(3)  
--declare @renovado   int  
--set @Usuario='curbiza'  
--set @Cuenta='098-211-06-2-6-01786'
--set @fraccioncta='0'  
--set @renovado=0  

Declare @UltimoCorte2 SmallDateTime  
Declare @PrimerCorte2 SmallDateTime  
set @PrimerCorte2=@PrimerCorte
set @UltimoCorte2=@UltimoCorte 
  
set nocount on  
--<<<<<<<<<<<<<<<<<<<  
DECLARE @fechaMax AS SMALLDATETIME;  
DECLARE @FechaApertura SMALLDATETIME;  
DECLARE @fechaCierre AS SMALLDATETIME;  
  
SELECT @fechaMax = FecCancelacion, @fechaCierre=FecCancelacion  
,@FechaApertura = FecApertura  
FROM tCsPadronAhorros  
--WHERE codcuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta;  
WHERE codcuenta= @Cuenta and FraccionCta=@fraccioncta and Renovado=@renovado  
--PRINT 'fecha max: ' + isnull(CONVERT(VARCHAR, @fechaMax),'');  
  
--select *  
--FROM tCsPadronAhorros  
--WHERE codcuenta= @Cuenta and FraccionCta=@fraccioncta and Renovado=@renovado  
  
IF @fechaMax > '19000101'  
    BEGIN  
        IF @fechaMax <= @UltimoCorte2   --Si la fechaMax en menor igual a la fecha corte  
            BEGIN  
                SELECT @fechaMax = MAX(Fecha)  
                FROM tCsAhorros WITH(NOLOCK)  
                WHERE codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  
        END;  
            ELSE  
            BEGIN  
                SET @fechaMax = @UltimoCorte2;  
        END;  
END;  
    ELSE  
    BEGIN  
        SET @fechaMax = @UltimoCorte2;  
 END;  
--PRINT 'fecha max: ' + isnull(CONVERT(VARCHAR, @fechaMax),'');  
  
IF @FechaApertura > @PrimerCorte2  
    BEGIN  
        SET @PrimerCorte2 = @FechaApertura;  
END;  
  
DECLARE @Firma VARCHAR(100);  
DECLARE @Parametro VARCHAR(50);  
DECLARE @AnteriorCorte SMALLDATETIME;  
DECLARE @LimitePago VARCHAR(20);  
DECLARE @Devengado DECIMAL(20, 4);  
DECLARE @SaldoAnterior DECIMAL(20, 4);  
DECLARE @CAT DECIMAL(10, 4);  
DECLARE @GATnominal MONEY;  
DECLARE @GATreal MONEY;  
DECLARE @RendimientosPeriodo MONEY;  
DECLARE @UDI MONEY;  
DECLARE @ValorUDIsEnPesos MONEY;  
DECLARE @SaldoInicialPeriodo MONEY;  
DECLARE @SaldoPromedio MONEY;  
DECLARE @DiasPeriodo INT;  
DECLARE @SaldoPromedioDiarios MONEY;  
DECLARE @ImpuestosPeriodo MONEY;  
  
SET @AnteriorCorte = DATEADD(day, -1, @PrimerCorte2);  
  
SELECT @CAT = dbo.fduCATPrestamo(4, SaldoCuenta, DATEDIFF(Day, @PrimerCorte2, @UltimoCorte2), TasaInteres, 0)  
FROM tCsAhorros with(nolock)  
WHERE Fecha = @fechaMax AND codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  --HLL 27/11/2023  
  
SET @Parametro = Replace(@Cuenta, '-', '');  
SET @Parametro = UPPER(dbo.fduNombreMes(MONTH(@UltimoCorte2)) + ' ' + CAST(YEAR(@UltimoCorte2) AS VARCHAR(4)));  
  
--SELECT @SaldoAnterior = SUM(Devengado - Pago)  
--FROM tCsEstadoCuentaCronograma WITH(NOLOCK)  
--WHERE Corte = @AnteriorCorte AND CodPrestamo = @Cuenta;  
  
select  
  @GatNominal = dbo.fduCATPrestamo(4, SaldoCuenta, isnull(Plazo,1), Tasainteres,                 
          CASE RIGHT(IsNull(Ltrim(rtrim(NULL)), '0.00%'), 1)                   
          WHEN '%' THEN   
           CAST(LEFT(Isnull(Ltrim(rtrim(NULL)), '0.00%'),  
                 Len(isnull(Ltrim(rtrim(NULL)), '0.00%')) - 1) AS Decimal(10, 4))                  
           / 100.0000 * SaldoCuenta  
          ELSE                 
          CAST(Isnull(Ltrim(rtrim(RIGHT(NULL, Len(NULL) - 1))), '0.00')                 
          AS Decimal(10, 4)) END),  
  
   @GatReal = dbo.fahgatreal(FechaApertura, dbo.fduCATPrestamo(4, SaldoCuenta, isnull(Plazo,1), Tasainteres,                 
              CASE RIGHT(IsNull(Ltrim(rtrim(NULL)), '0.00%'), 1)         
              WHEN '%' THEN   
               CAST(LEFT(Isnull(Ltrim(rtrim(NULL)), '0.00%'),  
                     Len(isnull(Ltrim(rtrim(NULL)), '0.00%')) - 1) AS Decimal(10, 4))                  
               / 100.0000 * SaldoCuenta                
              ELSE                 
              CAST(Isnull(Ltrim(rtrim(RIGHT(NULL, Len(NULL) - 1))), '0.00')                 
              AS Decimal(10, 4)) END))  
 --select *  
  from tcsahorros with(nolock)  
  WHERE fecha=@fechaMax AND codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado -- HLL 27/11//2023  
  
  --   SELECT @RendimientosPeriodo = SUM(MontoTotalTran)  
  --   FROM tCsTransaccionDiaria WITH(NOLOCK)  
  --WHERE codigocuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  
  --        AND Fecha >= @PrimerCorte2  
  --        AND Fecha <= @UltimoCorte2  
  --        AND TipoTransacNivel1 = 'I'  
  --        AND TipoTransacNivel3 = 15;  
  
-- HLL 27112023  
  
  --   SELECT @ImpuestosPeriodo = ISNULL(SUM(MontoTotalTran), 0)  
  --   FROM tCsTransaccionDiaria WITH(NOLOCK)  
--  WHERE codigocuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  
--          AND Fecha >= @PrimerCorte2  
 --         AND Fecha <= @UltimoCorte2  
 --         AND TipoTransacNivel1 = 'E'  
 --         AND TipoTransacNivel3 IN(62);  
  
-- HLL  
  
  
   SELECT @ImpuestosPeriodo = ISNULL(SUM(MontoTotalTran), 0)  
     FROM tCsTransaccionDiaria WITH(NOLOCK)  
  WHERE    Fecha >= @PrimerCorte2  
          AND Fecha <= @UltimoCorte2  
          AND  codigocuenta=@Cuenta   
          AND   FraccionCta=@FraccionCta   
          AND  Renovado=@Renovado  
          AND TipoTransacNivel1 = 'E'  
          AND TipoTransacNivel3 IN(62);   --HLL 27/11/2023  
           
     SELECT @UDI = UDI  
     FROM tcsudis WITH(NOLOCK)  
     WHERE Fecha = @fechaMax--@UltimoCorte2  
  
     SET @ValorUDIsEnPesos = @UDI * 25000;  
  
     SELECT @SaldoInicialPeriodo = SaldoCuenta  
     FROM tCsAhorros WITH(NOLOCK)  
  WHERE  fecha = @PrimerCorte2-1 AND codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  --HLL 27/11/2023  
            
  
     SET @SaldoPromedio =  
     (  
         SELECT AVG(SaldoCuenta)  
         FROM tcsahorros WITH(NOLOCK)  
   WHERE  Fecha>= @PrimerCorte2 AND Fecha<=@fechaMax    ---@UltimoCorte2   
   AND codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado --HLL 27/11/2023  
           
     );  
  
     SELECT @DiasPeriodo = DATEDIFF(d, @PrimerCorte2-1, case when @fechaMax<>@UltimoCorte2 then @fechacierre else @fechaMax end)--@UltimoCorte2);  
     SET @SaldoPromedioDiarios = @SaldoPromedio; --@SaldoPromedio / @DiasPeriodo  
     SET @LimitePago = 'INMEDIATO';  
  
     DECLARE @ResumenAbonos MONEY;  
     DECLARE @ResumenRendimientos MONEY;  
     DECLARE @ResumenCargos MONEY;  
     DECLARE @ResumenImpuestos MONEY;  
  DECLARE @Comisiones MONEY;  
     DECLARE @ResumenSaldoFinal MONEY;  
  
     SELECT @ResumenAbonos = SUM(x.Abonos), --as Abonos,   
            @ResumenRendimientos = SUM(x.Rendimientos), -- as Rendimientos,   
            @ResumenCargos = SUM(x.Cargos), -- as Cargos,   
            @ResumenImpuestos = SUM(x.Impuestos), -- as Impuestos,    
            @ResumenSaldoFinal = (CASE  
                                      WHEN LEFT(RIGHT(LEFT(@Cuenta, 7), 3), 1) = '2'  
                                      THEN @SaldoInicialPeriodo + SUM(x.Rendimientos) - SUM(x.Cargos)--@SaldoInicialPeriodo + @ResumenRendimientos - @ResumenCargos  
                                      ELSE(SUM(x.Abonos) + SUM(x.Rendimientos) - SUM(x.Cargos) - SUM(x.Impuestos))  
                                  END),  
   @Comisiones = sum(x.comisiones)  
     FROM  
     (  
         SELECT CASE  
                    WHEN t.TipoTransacNivel1 = 'I'  
                         AND TipoTransacNivel3 IN(2,4)  
                    THEN t.MontoTotalTran  
                    ELSE 0  
                END AS Abonos,  
                CASE   
                    WHEN(TipoTransacNivel3 IN(15, 7, 63))  
                   THEN t.MontoTotalTran  
                    ELSE 0  
                END AS Rendimientos,  
                CASE   
                    WHEN TipoTransacNivel3 IN(1,3, 7)  
                    THEN t.MontoTotalTran  
                    ELSE 0  
                END AS Cargos,  
                CASE  
                    WHEN t.TipoTransacNivel1 = 'E'  
                         AND TipoTransacNivel3 IN(62)  
                    THEN t.MontoTotalTran  
                    ELSE 0  
                END AS Impuestos  
    ,CASE  
                    WHEN t.TipoTransacNivel1 = 'E'  
                         AND TipoTransacNivel3 IN(16)  
                    THEN t.MontoTotalTran  
       ELSE 0  
                END AS comisiones  
         FROM tCsTransaccionDiaria t WITH(NOLOCK)  
         WHERE t.Fecha >= @PrimerCorte2  
              AND t.Fecha <= @UltimoCorte2  
              AND t.codigocuenta=@Cuenta   
 AND t.FraccionCta=@FraccionCta   
 AND t.Renovado=@Renovado  
             AND (t.CodSistema = 'AH')  
     ) AS x;  
    
  
     --OSC, 24-01-2019  
     --IF SUBSTRING(@Cuenta, 5, 3) <> '209'  
  IF (SUBSTRING(@Cuenta, 5, 1) = '2' and SUBSTRING(@Cuenta, 5, 3) <> '209')  
         BEGIN  
             SELECT @ResumenRendimientos = SUM(InteresCalculado)  
             FROM tcsahorros WITH(NOLOCK)  
             --WHERE (CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta)  
    WHERE Fecha >= @PrimerCorte2  
                 AND Fecha <= @UltimoCorte2  
    AND  codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  --HLL 27/11/2023  
               
     END;  
     -->>>>>>>>>>>>>>  
  
     SELECT @PrimerCorte2 AS Inicio,   
            case when @fechaMax<>@UltimoCorte2 then @fechacierre else @fechaMax end AS Corte, --@UltimoCorte2  
            DATEDIFF(Day, @PrimerCorte2-1, case when @fechaMax<>@UltimoCorte2 then @fechacierre else @fechaMax end) AS Dias, --@UltimoCorte2  
            @Parametro AS Periodo,   
            @Firma AS Firma,   
            CodPrestamo = @Cuenta,   
            a.CodUsuario,   
            NombreProdCorto = ap.Abreviatura,   
            NombreProd = ap.Nombre,   
            cl.UsRFCBD,   
            a.CodOficina  
            ,o.Tipo,   
            ProximoVencimiento = @UltimoCorte2,  
            --tAhClFormaManejo.Nombre AS Veridico,   
            --LEFT(General.ClienteGrupo, 35) AS ClienteGrupo,   
            m.DescMoneda,   
            a.FechaApertura AS FechaDesembolso,   
            FechaVencimiento = CASE  
                                   WHEN a.FechaVencimiento IS NULL  
                                   THEN 'INDEFINIDO'  
                                   ELSE dbo.fduFechaATexto(a.FechaVencimiento, 'DD') + '-' + LOWER(LEFT(dbo.fduNombreMes(MONTH(a.FechaVencimiento)), 3)) + '-' + dbo.fduFechaATexto(a.FechaVencimiento, 'AAAA')  
                               END  
            ,FechaVencimiento2 = CASE  
                                    WHEN a.FechaVencimiento IS NULL  
                                    THEN 'INDEFINIDO'  
                                    ELSE CONVERT(VARCHAR, a.FechaVencimiento, 103)  
                                END  
            ,a.TasaInteres AS TasaIntCorriente,   
            @CAT AS CAT,   
            a.SaldoCuenta AS SaldoCapital,   
            0 AS CargoMora,   
            0 AS OtrosCargos,   
             --0 AS Impuestos  
            @ImpuestosPeriodo AS Impuestos  
            --CASE  
            --    WHEN(ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) + ISNULL(Atrasado.InteresMoratorio, 0) + ISNULL(Atrasado.OtrosCargos, 0) + ISNULL(Atrasado.ComisionIVA, 0)) > 0  
            --    THEN 'INMEDIATO'  
            --    ELSE ''  
            --END AS LimitePago,   
            ,ISNULL(@SaldoAnterior, 0) AS SaldoAnterior,   
            --ISNULL(Cargos.CK, 0) AS CK,   
            --ISNULL(Cargos.CKC, 0) AS CKC,   
            --ISNULL(Cargos.CKI, 0) AS CKI,   
            --ISNULL(Abonos.AK, 0) AS AK,   
            cl.NombreCompleto,   
          ap.AlternativaUso   
            ,CAST(Replace(ISNULL(CASE  
                                    WHEN (ap.SaldoMinimo<>'NO APLICA' and ap.SaldoMinimo is not null)  
                                    THEN ap.SaldoMinimo  
                                    ELSE '0'  
                                END, '0'), '$', '') AS DECIMAL(8, 2)) SaldoMinimo  
            ,SaldoPromedio = @SaldoPromedio  
     --(  
     --    SELECT AVG(SaldoCuenta)  
     --    FROM tcsahorros with(nolock)  
     --    WHERE CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta  
     --          AND (Fecha >= @PrimerCorte2)  
     --          AND (Fecha <= @UltimoCorte2)  
     --),   
            ,MontoBloqueado = a.MontoBloqueado,   
            SaldoDisponible = (CASE p.EstadoCalculado WHEN 'CC'   
               THEN 0  
                               ELSE a.SaldoCuenta - a.MontoBloqueado   
                               END),   
            p.MonApertura AS SaldoApertura,   
            ISNULL(p.MonCancelacion, a.SaldoCuenta) AS SaldoCancelacion,  
            CASE when p.EstadoCalculado='CC' THEN 0  
                ELSE a.IntAcumulado END AS InteresAcumulado,   
            a.MontoRetenido,   
            ISNULL(a.Plazo, 0) AS Plazo,   
            ISNULL(CONVERT(VARCHAR, a.Plazo), 'NO APLICA') AS Plazo2,  
            CASE when p.EstadoCalculado='CC' THEN 0  
                else a.IntAcumulado END AS InteresAcumulado2,   
            @GATnominal AS GATnominal,   
            @GATreal AS GATreal,   
            ISNULL(@RendimientosPeriodo, 0) AS RendimientosPeriodo,   
            @ValorUDIsEnPesos AS UDISenPesos,   
            ISNULL(@SaldoInicialPeriodo, 0) AS SaldoInicialPeriodo,   
            ISNULL(@SaldoPromedioDiarios, 0) AS SaldoPromedioDiarios,   
            ISNULL(@DiasPeriodo, 0) AS DiasPeriodo,   
            @ResumenAbonos AS ResumenAbonos,   
            @ResumenRendimientos AS ResumenRendimientos,   
            @ResumenCargos AS ResumenCargos,   
            @ResumenImpuestos AS ResumenImpuestos,   
            --@ResumenSaldoFinal AS ResumenSaldoFinal  
   case when @fechaMax<>@UltimoCorte2 then 0 else a.saldocuenta end ResumenSaldoFinal  
   ,@Comisiones Comisiones  
 ---select a.*  
     FROM tCsAhorros a WITH(NOLOCK)  
  INNER JOIN tCsPadronAhorros p WITH(NOLOCK) on a.codcuenta=p.codcuenta and a.fraccioncta=p.fraccioncta and a.renovado=p.renovado  
     INNER JOIN tClOficinas o WITH(NOLOCK) ON o.CodOficina=a.CodOficina  
     INNER JOIN tAhProductos ap WITH(NOLOCK) ON a.CodProducto=ap.idProducto   
  LEFT JOIN tCsPadronClientes cl WITH(NOLOCK) ON a.Codusuario=cl.CodUsuario  
  INNER JOIN tClMonedas m WITH(NOLOCK) ON m.CodMoneda = a.CodMoneda  
 WHERE a.fecha=@fechaMax and a.codcuenta=@Cuenta and a.FraccionCta=@FraccionCta and a.Renovado=@Renovado --HLL 27/11/2023
GO