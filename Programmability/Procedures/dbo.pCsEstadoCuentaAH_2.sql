SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsEstadoCuentaAH_2] @Usuario     VARCHAR(50), 
                                             @Cuenta      VARCHAR(25), 
                                             @PrimerCorte SMALLDATETIME, 
                                             @UltimoCorte SMALLDATETIME
AS

/*
declare	@Usuario		Varchar(50)
declare	@Cuenta			Varchar(25)
set @Usuario='curbiza'
set @Cuenta='098-209-06-2-0-00001-0-0' 
--set @Cuenta='098-211-06-2-7-00070-0-1'
Declare @UltimoCorte	SmallDateTime
Declare @PrimerCorte	SmallDateTime
set @PrimerCorte='20170505'
set @UltimoCorte='20190105'
--set @PrimerCorte='20170929'
--set @UltimoCorte='20180118'
*/

     SET @PrimerCorte = CONVERT(VARCHAR, @PrimerCorte, 112);
     SET @UltimoCorte = CONVERT(VARCHAR, @UltimoCorte, 112);

     --<<<<<<<<<<<<<<<<<<<
     DECLARE @fechaMax AS SMALLDATETIME;
     DECLARE @FechaApertura SMALLDATETIME;
     SELECT @fechaMax = ISNULL(FecCancelacion, ''), 
            @FechaApertura = FecApertura
     FROM tCsPadronAhorros
     WHERE codcuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta;
     PRINT 'fecha max: ' + CONVERT(VARCHAR, @fechaMax);
     IF @fechaMax > '19000101'
         BEGIN
             IF @fechaMax <= @UltimoCorte   --Si la fechaMax en menor igual a la fecha corte
                 BEGIN
                     --set @fechaMax = dateadd( d, -1, @fechaMax)
                     --print 'ajusta la fecha max = FechaCancelacion -1 dia: ' + convert(varchar,@fechaMax)

                     SELECT @fechaMax = MAX(Fecha)
                     FROM tCsAhorros WITH(NOLOCK)
                     WHERE codcuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta;
                     PRINT 'obtiene la fechamax de tCsAhorros: ' + CONVERT(VARCHAR, @fechaMax);
             END;
                 ELSE
                 BEGIN
                     SET @fechaMax = @UltimoCorte;
                     PRINT 'ajusta la fecha max = fecha ultimo corte: ' + CONVERT(VARCHAR, @fechaMax);
             END;
     END;
         ELSE
         BEGIN
             SET @fechaMax = @UltimoCorte;
             PRINT 'ajusta la fecha max = FechaCorte ' + CONVERT(VARCHAR, @fechaMax);
     END;
     PRINT 'fecha max: ' + CONVERT(VARCHAR, @fechaMax);
     PRINT 'fecha Apertura: ' + CONVERT(VARCHAR, @FechaApertura);
     IF @FechaApertura > @PrimerCorte
         BEGIN
             SET @PrimerCorte = @FechaApertura;
             PRINT 'Fecha Apertura mayor a fecha inicial '; 
             --select @DiasPeriodo = datediff(d, @FechaApertura, @UltimoCorte)
     END;
         ELSE
         BEGIN
             PRINT 'Fecha Apertura menor a fecha incial'; 
             --select @DiasPeriodo = datediff(d, @PrimerCorte, @UltimoCorte)
     END;
     PRINT 'Fecha Primer Corte: ' + CONVERT(VARCHAR, @PrimerCorte);

     -->>>>>>>>>>>>>>>>>>>
     --POR EL MOMENTO NO SE UTILIZA LA VARIABLE @DATO
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
     IF LTRIM(RTRIM(@Usuario)) = ''
         BEGIN
             SELECT TOP 1 @Usuario = Usuario
             FROM tSgUsuarios WITH(NOLOCK)
             WHERE Activo = 1
                   AND LTRIM(RTRIM(Usuario)) <> ''
             ORDER BY NEWID();
     END;
     IF LTRIM(RTRIM(@Cuenta)) = ''
         BEGIN
             SELECT TOP 1 @Cuenta = CodPrestamo
             FROM
             (
                 SELECT DISTINCT 
                        CodPrestamo
                 FROM tCsPadronCarteraDet WITH(NOLOCK)
                 WHERE EstadoCalculado NOT IN('CANCELADO')
             ) Datos
             ORDER BY NEWID();
     END;
     SET @AnteriorCorte = DATEADD(day, -1, @PrimerCorte);

     /*pendiente*/
	 ---SE COMETARON O2-03-2020
     --EXEC pCsEstadoCuentaCronograma 
     --     2, 
     --     @Cuenta, 
     --     @UltimoCorte;
     --EXEC pCsEstadoCuentaCronograma 
     --     2, 
     --     @Cuenta, 
     --     @AnteriorCorte;
     --EXEC pCsEstadoCuentaCAMovimientos 
     --     2, 
     --     @Cuenta, 
     --     @PrimerCorte, 
     --     @UltimoCorte;

     --Print	@AnteriorCorte
     --Print	@UltimoCorte

     SELECT TOP 1 @CAT = dbo.fduCATPrestamo(4, SaldoCuenta, DATEDIFF(Day, @PrimerCorte, @UltimoCorte), TasaInteres, 0)
     FROM tCsAhorros
     WHERE(CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta)
          AND (Fecha <= @UltimoCorte)
     ORDER BY Fecha DESC;
     CREATE TABLE #Saldos
     ([CodPrestamo]      [VARCHAR](25) NOT NULL, 
      [Concepto]         [VARCHAR](100) NULL, 
      [SaldoCapital]     [MONEY] NULL, 
      [InteresOrdinario] [MONEY] NULL, 
      [InteresMoratorio] [MONEY] NULL, 
      [OtrosCargos]      [MONEY] NULL, 
      [ComisionIVA]      [MONEY] NULL
     )
     ON [PRIMARY];
     INSERT INTO #Saldos
     EXEC pCsEstadoCuentaCASaldos 
          1, 
          @Cuenta, 
          @UltimoCorte, 
          'Vigente Actual';
     INSERT INTO #Saldos
     EXEC pCsEstadoCuentaCASaldos 
          2, 
          @Cuenta, 
          @UltimoCorte, 
          'Atraso Actual';
     SET @Parametro = Replace(@Cuenta, '-', '');
     SET @Parametro = UPPER(dbo.fduNombreMes(MONTH(@UltimoCorte)) + ' ' + CAST(YEAR(@UltimoCorte) AS VARCHAR(4)));
     SELECT @SaldoAnterior = SUM(Devengado - Pago)
     FROM tCsEstadoCuentaCronograma WITH(NOLOCK)
     WHERE Corte = @AnteriorCorte
           AND CodPrestamo = @Cuenta;

     --OSC, Obtiene el GAT Real y Nominal
     SELECT @GATnominal = GatNominal, 
            @GATreal = GatReal
     FROM [10.0.2.14].finmas.dbo.vAhGatNominalReal
     WHERE codcuenta2 = @Cuenta;

     --OSC-- Print @SaldoAnterior
     --OSC, obtiene los interese en el periodo
     SELECT @RendimientosPeriodo = SUM(MontoTotalTran)
     FROM tCsTransaccionDiaria WITH(NOLOCK)
     WHERE(CodigoCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta)
          AND Fecha >= @PrimerCorte
          AND Fecha <= @UltimoCorte
          AND TipoTransacNivel1 = 'I'
          AND TipoTransacNivel3 = 15;

     --OSC, obtiene los impuestos en el periodo
     SELECT @ImpuestosPeriodo = ISNULL(SUM(MontoTotalTran), 0)
     FROM tCsTransaccionDiaria WITH(NOLOCK)
     WHERE(CodigoCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta)
          AND Fecha >= @PrimerCorte
          AND Fecha <= @UltimoCorte
          AND TipoTransacNivel1 = 'E'
          AND TipoTransacNivel3 IN(62);

     --OSC, obtiene el valor de udis en pesos
     SELECT TOP 1 @UDI = UDI
     FROM tcsudis WITH(NOLOCK)
     WHERE Fecha <= @UltimoCorte
     ORDER BY Fecha DESC;
     SET @ValorUDIsEnPesos = @UDI * 25000;

     --OSC, obtiene el saldo inicial del periodo
     SELECT TOP 1 @SaldoInicialPeriodo = SaldoCuenta --, Fecha, CodCuenta, FraccionCta, Renovado 
     FROM tCsAhorros WITH(NOLOCK)
     WHERE(CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta)
          AND fecha <= @PrimerCorte
     ORDER BY fecha DESC;

     --OSC, obtiene el saldo promedio del periodo
     SET @SaldoPromedio =
     (
         SELECT AVG(SaldoCuenta)
         FROM tcsahorros WITH(NOLOCK)
         WHERE CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta
               AND (Fecha >= @PrimerCorte)
               AND (Fecha <= @UltimoCorte)
     );

     --OSC, obtiene el numero de dias del periodo
     --select @PrimerCorte, @UltimoCorte
     SELECT @DiasPeriodo = DATEDIFF(d, @PrimerCorte, @UltimoCorte);
     --set @DiasPeriodo = @DiasPeriodo + 1
     --select @DiasPeriodo
     --OSC, obtiene el saldo promedio diario
     SET @SaldoPromedioDiarios = @SaldoPromedio; --@SaldoPromedio / @DiasPeriodo

     SET @LimitePago = 'INMEDIATO';

     --OSC 24-01-2019
     SET @SaldoInicialPeriodo = 0;

     --<<<<<<<<<<<<<< OSC, 15-05-2018, calculo de resumen operaciones
     DECLARE @ResumenAbonos MONEY;
     DECLARE @ResumenRendimientos MONEY;
     DECLARE @ResumenCargos MONEY;
     DECLARE @ResumenImpuestos MONEY;
     DECLARE @ResumenSaldoFinal MONEY;
     SELECT @ResumenAbonos = SUM(x.Abonos), --as Abonos, 
            @ResumenRendimientos = SUM(x.Rendimientos), -- as Rendimientos, 
            @ResumenCargos = SUM(x.Cargos), -- as Cargos, 
            @ResumenImpuestos = SUM(x.Impuestos), -- as Impuestos,  
            --@ResumenSaldoFinal = (sum(x.Abonos) + sum(x.Rendimientos)- sum(x.Cargos)-sum(x.Impuestos)) -- as SaldoFinal
            @ResumenSaldoFinal = (CASE
                                      WHEN LEFT(RIGHT(LEFT(@Cuenta, 7), 3), 1) = '2'
                                      THEN @SaldoInicialPeriodo + @ResumenRendimientos - @ResumenCargos
                                      ELSE(SUM(x.Abonos) + SUM(x.Rendimientos) - SUM(x.Cargos) - SUM(x.Impuestos))
                                  END)
     FROM
     (
         SELECT CASE
                    WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'I'
                         AND TipoTransacNivel3 IN(2)
                    THEN tCsTransaccionDiaria.MontoTotalTran
                    ELSE 0
                END AS Abonos,
                CASE 
                       --WHEN (tCsTransaccionDiaria.TipoTransacNivel1 = 'I' and TipoTransacNivel3 in (15,7)) or (tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (63)) THEN tCsTransaccionDiaria.MontoTotalTran  
                    WHEN(TipoTransacNivel3 IN(15, 7, 63))
                    THEN tCsTransaccionDiaria.MontoTotalTran
                    ELSE 0
                END AS Rendimientos,
                CASE 
                       --WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (1)  THEN tCsTransaccionDiaria.MontoTotalTran  
                    WHEN TipoTransacNivel3 IN(1, 7)
                    THEN tCsTransaccionDiaria.MontoTotalTran
                    ELSE 0
                END AS Cargos,
                CASE
                    WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E'
                         AND TipoTransacNivel3 IN(62)
                    THEN tCsTransaccionDiaria.MontoTotalTran
                    ELSE 0
                END AS Impuestos
         FROM tCsTransaccionDiaria WITH(NOLOCK)
              LEFT OUTER JOIN tClOficinas WITH(NOLOCK) ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina
              LEFT OUTER JOIN tAhClTipoTrans WITH(NOLOCK) ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
              LEFT JOIN tCsAhorros AS a WITH(NOLOCK) ON a.codcuenta = tCsTransaccionDiaria.CodigoCuenta
                                                        AND a.FraccionCta = tCsTransaccionDiaria.FraccionCta
                                                        AND a.Renovado = tCsTransaccionDiaria.Renovado
                                                        AND a.Fecha = tCsTransaccionDiaria.Fecha
         WHERE(tCsTransaccionDiaria.Fecha >= @PrimerCorte)
              AND (tCsTransaccionDiaria.Fecha <= @ultimoCorte)
              AND (tCsTransaccionDiaria.CodSistema = 'AH')
              AND (tCsTransaccionDiaria.CodigoCuenta + '-' + tCsTransaccionDiaria.FraccionCta + '-' + CAST(tCsTransaccionDiaria.Renovado AS VARCHAR(5)) = @Cuenta)
         --order by tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.NroTransaccion
     ) AS x;

/* boorar
select 
@SaldoInicialPeriodo = 
(
isnull(sum(
case  
   when tt.EsDebito = 0 then td.MontoTotalTran 
   else 0 
end
),0)
) 
-
(
isnull(sum(
case  
   when tt.EsDebito = 1 then td.MontoTotalTran 
   else 0 
end
),0)
)
from tCsTransaccionDiaria as td
inner join tAhClTipoTrans as tt on tt.idTipoTrans = td.TipoTransacNivel3
where (td.CodigoCuenta  + '-' + td.FraccionCta + '-' + CAST(td.Renovado AS varchar(5)) = @Cuenta) 
and td.Fecha < @Inicio

*/

     --OSC, 24-01-2019
     IF SUBSTRING(@Cuenta, 5, 3) <> '209'
         BEGIN
             SELECT @ResumenRendimientos = SUM(InteresCalculado)
             FROM tcsahorros WITH(NOLOCK)
             WHERE 
             --CodCuenta = '098-211-06-2-0-00153' and FraccionCta = 0 and Renovado = 0
             (CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta)
             AND Fecha >= @PrimerCorte
             AND Fecha <= @ultimoCorte;
     END;
     -->>>>>>>>>>>>>>

     SELECT @PrimerCorte AS Inicio, 
            @UltimoCorte AS Corte, 
            DATEDIFF(Day, @PrimerCorte, @UltimoCorte) AS Dias, 
            @Parametro AS Periodo, 
            @Firma AS Firma, 
            CodPrestamo = @Cuenta, 
            tCsClientesAhorrosFecha_2.CodUsCuenta AS CodUsuario, 
            NombreProdCorto = tAhProductos.Abreviatura, 
            NombreProd = tAhProductos.Nombre, 
            tCsPadronClientes.UsRFCBD, 
            tCsPadronAhorros.CodOficina, 
            tClOficinas.Tipo, 
            ProximoVencimiento = @UltimoCorte, 
            tAhClFormaManejo.Nombre AS Veridico, 
            LEFT(General.ClienteGrupo, 35) AS ClienteGrupo, 
            General.DescMoneda, 
            tCsAhorros.FechaApertura AS FechaDesembolso, 
            FechaVencimiento = CASE
                                   WHEN tCsAhorros.FechaVencimiento IS NULL
                                   THEN 'INDEFINIDO'
                                   ELSE dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'DD') + '-' + LOWER(LEFT(dbo.fduNombreMes(MONTH(tCsAhorros.FechaVencimiento)), 3)) + '-' + dbo.fduFechaATexto(tCsAhorros.FechaVencimiento, 'AAAA')
                               END, 
            FechaVencimiento2 = CASE
                                    WHEN tCsAhorros.FechaVencimiento IS NULL
                                    THEN 'INDEFINIDO'
                                    ELSE CONVERT(VARCHAR, tCsAhorros.FechaVencimiento, 103)
                                END, 
            tCsAhorros.TasaInteres AS TasaIntCorriente, 
            @CAT AS CAT, 
            tCsAhorros.SaldoCuenta AS SaldoCapital, 
            0 AS CargoMora, 
            0 AS OtrosCargos, 
             --0 AS Impuestos
            @ImpuestosPeriodo AS Impuestos,
            CASE
                WHEN(ISNULL(Atrasado.SaldoCapital, 0) + ISNULL(Atrasado.InteresOrdinario, 0) + ISNULL(Atrasado.InteresMoratorio, 0) + ISNULL(Atrasado.OtrosCargos, 0) + ISNULL(Atrasado.ComisionIVA, 0)) > 0
                THEN 'INMEDIATO'
                ELSE ''
            END AS LimitePago, 
            ISNULL(@SaldoAnterior, 0) AS SaldoAnterior, 
            ISNULL(Cargos.CK, 0) AS CK, 
            ISNULL(Cargos.CKC, 0) AS CKC, 
            ISNULL(Cargos.CKI, 0) AS CKI, 
            ISNULL(Abonos.AK, 0) AS AK, 
            tCsPadronClientes.NombreCompleto, 
            tAhProductos.AlternativaUso, 
            CAST(Replace(ISNULL(CASE
                                    WHEN tAhProductos.SaldoMinimo = 'NO APLICA'
                                    THEN '0'
                                    ELSE tAhProductos.SaldoMinimo
                                END, '0'), '$', '') AS DECIMAL(8, 2)) SaldoMinimo, 
            SaldoPromedio =
     (
         SELECT AVG(SaldoCuenta)
         FROM tcsahorros
         WHERE CodCuenta + '-' + FraccionCta + '-' + CAST(Renovado AS VARCHAR(5)) = @Cuenta
               AND (Fecha >= @PrimerCorte)
               AND (Fecha <= @UltimoCorte)
     ), 
            MontoBloqueado = tCsAhorros.MontoBloqueado, 
            SaldoDisponible = (CASE tCsPadronAhorros.EstadoCalculado
                                   WHEN 'CC'
                                   THEN 0
                                   ELSE tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado - (CASE
                                                                                                  WHEN tCsAhorros.SaldoCuenta - tCsAhorros.MontoBloqueado < (CASE
                                                                                                                                                                 WHEN tAhProductos.SaldoMinimo = 'NO APLICA'
                                                                                                                                                                 THEN 0
                                                                                                                                                                 ELSE CAST(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') AS DECIMAL(18, 4))
                                                                                                                                                             END)
                                                                                                  THEN 0
                                                                                                  ELSE(CASE
                                                                                                           WHEN tAhProductos.SaldoMinimo = 'NO APLICA'
                                                                                                           THEN 0
                                                                                                           ELSE CAST(Replace(Replace(tAhProductos.SaldoMinimo, '$', ''), ',', '') AS DECIMAL(18, 4))
                                                                                                       END)
                                                                                              END)
                               END), 
            tCsPadronAhorros.MonApertura AS SaldoApertura, 
            ISNULL(tCsPadronAhorros.MonCancelacion, tCsAhorros.SaldoCuenta) AS SaldoCancelacion,
            CASE
                WHEN ISNULL(tCsPadronAhorros.MonCancelacion, 0) = 0
                THEN 0
                ELSE tCsAhorros.IntAcumulado
            END AS InteresAcumulado, 
            tCsAhorros.MontoRetenido, 
            ISNULL(tCsAhorros.Plazo, 0) AS Plazo, 
            ISNULL(CONVERT(VARCHAR, tCsAhorros.Plazo), 'NO APLICA') AS Plazo2,
            CASE
                WHEN ISNULL(tCsPadronAhorros.MonCancelacion, 0) = 0
                THEN tCsAhorros.IntAcumulado
                ELSE 0
            END AS InteresAcumulado2, 
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
            @ResumenSaldoFinal AS ResumenSaldoFinal
     FROM
     (
         SELECT *
         FROM [#Saldos] AS [#Saldos_1]
         WHERE(Concepto = 'Atraso Actual')
     ) AS Atrasado
     RIGHT OUTER JOIN
     (
         SELECT CodCuenta, 
                FraccionCta, 
                Renovado, 
                SUM(AK) AS AK, 
                SUM(AI) AS AI, 
                SUM(AM) AS AM, 
                SUM(AC) AS AC, 
                SUM(AIVA) AS AIVA
         FROM
         (
             SELECT CodCuenta, 
                    FraccionCta, 
                    Renovado,
                    CASE CodConcepto
                        WHEN 'CAPI'
                        THEN Pago
                        ELSE 0
                    END AS AK,
                    CASE CodConcepto
                        WHEN 'INTE'
                        THEN Pago
                        ELSE 0
                    END AS AI,
                    CASE CodConcepto
                        WHEN 'INPE'
                        THEN Pago
                        ELSE 0
                    END AS AM,
                    CASE CodConcepto
                        WHEN 'MORA'
                        THEN Pago
                        ELSE 0
                    END AS AC,
                    CASE
                        WHEN CodConcepto IN('IVAIT', 'IVACM', 'IVAMO')
                        THEN Pago
                        ELSE 0
                    END AS AIVA
             FROM
             (
                 SELECT tCsTransaccionDiaria.CodigoCuenta AS CodCuenta, 
                        tCsTransaccionDiaria.FraccionCta, 
                        tCsTransaccionDiaria.Renovado, 
                        'CAPI' AS CodConcepto, 
                        SUM(tCsTransaccionDiaria.MontoTotalTran) AS Pago
                 FROM tCsTransaccionDiaria WITH(NOLOCK)
                      LEFT OUTER JOIN tClOficinas AS tClOficinas_1 WITH(NOLOCK) ON tCsTransaccionDiaria.CodOficina = tClOficinas_1.CodOficina
                      LEFT OUTER JOIN tAhClTipoTrans WITH(NOLOCK) ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
                 WHERE(tCsTransaccionDiaria.TipoTransacNivel1 = 'E')
                      AND (tCsTransaccionDiaria.Fecha >= @PrimerCorte)
                      AND (tCsTransaccionDiaria.Fecha <= @UltimoCorte)
                      AND (tCsTransaccionDiaria.CodSistema = 'AH')
                      AND (tCsTransaccionDiaria.CodigoCuenta + '-' + tCsTransaccionDiaria.FraccionCta + '-' + CAST(tCsTransaccionDiaria.Renovado AS VARCHAR(5)) = @Cuenta)
                 GROUP BY tCsTransaccionDiaria.CodigoCuenta, 
                          tCsTransaccionDiaria.FraccionCta, 
                          tCsTransaccionDiaria.Renovado
             ) AS Datos_3
         ) AS Datos_4
         GROUP BY CodCuenta, 
                  FraccionCta, 
                  Renovado
     ) AS Abonos
     RIGHT OUTER JOIN
     (
         SELECT CodPrestamo, 
                SUM(CK) AS CK, 
                SUM(CKC) AS CKC, 
                SUM(CKI) AS CKI, 
                SUM(CI) AS CI, 
                SUM(CM) AS CM, 
                SUM(CC) AS CC, 
                SUM(CIVA) AS CIVA
         FROM
         (
             SELECT Cuenta AS CodPrestamo,
                    CASE
                        WHEN CodConcepto IN('CAPI')
                        THEN CargoD
                        ELSE 0
                    END AS CK,
                    CASE
                        WHEN CodConcepto IN('CAPI')
                             AND Concepto NOT LIKE '%Capitalizacion%'
                        THEN CargoD
                        ELSE 0
                    END AS CKC,
                    CASE
                        WHEN CodConcepto IN('CAPI')
                             AND Concepto LIKE '%Capitalizacion%'
                        THEN CargoD
                        ELSE 0
                    END AS CKI,
                    CASE
                        WHEN CodConcepto IN('INTE')
                        THEN CargoD
                        ELSE 0
                    END AS CI,
                    CASE
                        WHEN CodConcepto IN('INPE')
                        THEN CargoD
                        ELSE 0
                    END AS CM,
                    CASE
                        WHEN CodConcepto IN('MORA')
                        THEN CargoD
                        ELSE 0
                    END AS CC,
                    CASE
                        WHEN CodConcepto IN('IVAIT', 'IVACM', 'IVAMO')
                        THEN CargoD
                        ELSE 0
                    END AS CIVA
             FROM tCsEstadoCuentaMO WITH(NOLOCK)
             WHERE(Cuenta = @Cuenta)
                  AND (Fecha >= @PrimerCorte)
                  AND (Fecha <= @UltimoCorte)
                  AND (Sistema = 'AH')
         ) AS Datos
         GROUP BY CodPrestamo
     ) AS Cargos
     RIGHT OUTER JOIN tCsAhorros WITH(NOLOCK)
     INNER JOIN tClOficinas WITH(NOLOCK)
     INNER JOIN tCsPadronAhorros WITH(NOLOCK) ON tClOficinas.CodOficina = tCsPadronAhorros.CodOficina
     INNER JOIN tAhProductos WITH(NOLOCK) ON tCsPadronAhorros.CodProducto = tAhProductos.idProducto ON tCsAhorros.CodCuenta = tCsPadronAhorros.CodCuenta
                                                                                                       AND tCsAhorros.FraccionCta = tCsPadronAhorros.FraccionCta
                                                                                                       AND tCsAhorros.Renovado = tCsPadronAhorros.Renovado
     INNER JOIN
     (
         SELECT tCsAhorros_1.CodCuenta, 
                tCsAhorros_1.FraccionCta, 
                tCsAhorros_1.Renovado, 
                tCsClientesAhorrosFecha_1.CodUsCuenta AS CodUsuario, 
                tCsAhorros_1.SaldoCuenta AS MontoDesembolso, 
                tCsClientesAhorrosFecha_1.Capital AS Monto, 
                tCsClientesAhorrosFecha_1.Capital / tCsAhorros_1.SaldoCuenta * 100.000 AS Concentracion, 
                tCsPadronCarteraDet.Integrantes, 
                tCsPadronCarteraDet.ClienteGrupo, 
                tClMonedas.DescMoneda
         FROM
         (
             SELECT CodCuenta, 
                    FraccionCta, 
                    Renovado, 
                    COUNT(*) AS Integrantes, 
                    MAX(ClienteGrupo) AS ClienteGrupo
             FROM
             (
                 SELECT tCsAhorros_2.CodCuenta, 
                        tCsAhorros_2.FraccionCta, 
                        tCsAhorros_2.Renovado, 
                        tCsClientesAhorrosFecha.CodUsCuenta AS CodUsuario, 
                        ISNULL(tCsPadronClientes_1.NombreCompleto, '') AS ClienteGrupo
                 FROM tCsClientesAhorrosFecha WITH(NOLOCK)
                      INNER JOIN tCsAhorros AS tCsAhorros_2 WITH(NOLOCK) ON tCsClientesAhorrosFecha.Fecha = tCsAhorros_2.Fecha
                                                                            AND tCsClientesAhorrosFecha.CodCuenta = tCsAhorros_2.CodCuenta
                                                                            AND tCsClientesAhorrosFecha.FraccionCta = tCsAhorros_2.FraccionCta
                                                                            AND tCsClientesAhorrosFecha.Renovado = tCsAhorros_2.Renovado
                      LEFT OUTER JOIN tCsPadronClientes AS tCsPadronClientes_1 WITH(NOLOCK) ON tCsAhorros_2.CodUsuario = tCsPadronClientes_1.CodUsuario
                 WHERE 
                 --(tCsAhorros_2.Fecha = @UltimoCorte) AND (tCsAhorros_2.CodCuenta + '-' + CAST(tCsAhorros_2.Renovado AS varchar(5)) + '-' + tCsAhorros_2.FraccionCta = @Cuenta) ERROR
                 -- (tCsAhorros_2.Fecha = @UltimoCorte) --cambiado para soportar un rango mayo de fecha
                 (tCsAhorros_2.Fecha = @fechaMax)
                 AND (tCsAhorros_2.CodCuenta + '-' + tCsAhorros_2.FraccionCta + '-' + CAST(tCsAhorros_2.Renovado AS VARCHAR(5)) = @Cuenta)
             ) AS Datos_2
             GROUP BY CodCuenta, 
                      FraccionCta, 
                      Renovado
         ) AS tCsPadronCarteraDet
         INNER JOIN tCsAhorros AS tCsAhorros_1 WITH(NOLOCK) ON tCsPadronCarteraDet.CodCuenta = tCsAhorros_1.CodCuenta
                                                               AND tCsPadronCarteraDet.FraccionCta = tCsAhorros_1.FraccionCta
                                                               AND tCsPadronCarteraDet.Renovado = tCsAhorros_1.Renovado
         INNER JOIN tClMonedas WITH(NOLOCK) ON tClMonedas.CodMoneda = tCsAhorros_1.CodMoneda
         INNER JOIN tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_1 WITH(NOLOCK) ON tCsClientesAhorrosFecha_1.CodCuenta = tCsAhorros_1.CodCuenta
                                                                                         AND tCsClientesAhorrosFecha_1.FraccionCta = tCsAhorros_1.FraccionCta
                                                                                         AND tCsClientesAhorrosFecha_1.Renovado = tCsAhorros_1.Renovado
                                                                                         AND tCsClientesAhorrosFecha_1.Fecha = tCsAhorros_1.Fecha
         WHERE(tCsAhorros_1.CodCuenta + '-' + tCsAhorros_1.FraccionCta + '-' + CAST(tCsAhorros_1.Renovado AS VARCHAR(5)) = @Cuenta)
              AND --(tCsAhorros_1.Fecha = @UltimoCorte)
              (tCsAhorros_1.Fecha = @fechaMax) --cambiado para soportar un rango mayo de fecha

     ) AS General
     INNER JOIN tCsClientesAhorrosFecha AS tCsClientesAhorrosFecha_2 WITH(NOLOCK) ON General.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta
                                                                                     AND General.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta
                                                                                     AND General.Renovado = tCsClientesAhorrosFecha_2.Renovado
                                                                                     AND General.CodUsuario = tCsClientesAhorrosFecha_2.CodUsCuenta 
         --INNER JOIN
     LEFT JOIN tCsPadronClientes WITH(NOLOCK) ON tCsClientesAhorrosFecha_2.CodUsCuenta = tCsPadronClientes.CodUsuario
     INNER JOIN tAhClFormaManejo WITH(NOLOCK) ON tCsClientesAhorrosFecha_2.FormaManejo = tAhClFormaManejo.FormaManejo ON tCsAhorros.Fecha = tCsClientesAhorrosFecha_2.Fecha
                                                                                                                         AND tCsAhorros.CodCuenta = tCsClientesAhorrosFecha_2.CodCuenta
                                                                                                                         AND tCsAhorros.FraccionCta = tCsClientesAhorrosFecha_2.FraccionCta
                                                                                                                         AND tCsAhorros.Renovado = tCsClientesAhorrosFecha_2.Renovado ON Cargos.CodPrestamo = tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS VARCHAR(5)) ON Abonos.CodCuenta = tCsPadronAhorros.CodCuenta
                                                                                                                                                                                                                                                                                                                                       AND Abonos.FraccionCta = tCsPadronAhorros.FraccionCta
                                                                                                                                                                                                                                                                                                                                       AND Abonos.Renovado = tCsPadronAhorros.Renovado --ON tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS varchar(5)) = Vigente.CodPrestamo
         ON tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS VARCHAR(5)) = Atrasado.CodPrestamo
     WHERE(tCsPadronAhorros.CodCuenta + '-' + tCsPadronAhorros.FraccionCta + '-' + CAST(tCsPadronAhorros.Renovado AS VARCHAR(5)) = @Cuenta)
          AND --(tCsClientesAhorrosFecha_2.Fecha = @UltimoCorte)
          (tCsClientesAhorrosFecha_2.Fecha = @fechaMax) --cambiado para soportar un rango mayo de fecha
          --End

          AND tCsClientesAhorrosFecha_2.coordinador = 1;
     DROP TABLE #Saldos;
GO