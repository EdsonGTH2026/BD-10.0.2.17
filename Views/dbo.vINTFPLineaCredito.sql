SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vINTFPLineaCredito]
AS
SELECT DISTINCT 
                      dbo.tCsPagoDet.CodPrestamo, SUBSTRING(tINTFCuenta.Responsabilidad, 5, 1) AS Responsabilidad, SUBSTRING(tINTFCuenta.TipoCuenta, 5, 1) AS TipoCuenta, 
                      SUBSTRING(tINTFCuenta.TipoContrato, 5, 2) AS TipoContrato, SUBSTRING(tINTFCuenta.UnidadMonetaria, 5, 2) AS TipoMoneda, 
                      SUBSTRING(tINTFCuenta.NumeroPagos, 5, 2) AS NumeroPagos, SUBSTRING(tINTFCuenta.FrecuenciaPagos, 5, 1) AS FrecuenciaPagos, 
                      CASE WHEN tCsPadronCarteraDet.Cancelacion > Corte THEN SUBSTRING(tINTFCuenta.MontoPagar, 5, 10) WHEN tCsPadronCarteraDet.Cancelacion IS NULL 
                      THEN SUBSTRING(tINTFCuenta.MontoPagar, 5, 10) ELSE 0 END AS MontoPagar, SUBSTRING(tINTFCuenta.Apertura, 5, 20) AS Apertura, 
                      dbo.fduFechaATexto(dbo.tCsPagoDet.Fecha, 'DDMMAAAA') AS UltimoPago, SUBSTRING(tINTFCuenta.Disposicion, 5, 20) AS Compra, 
                      CASE WHEN tCsPadronCarteraDet.Cancelacion > Corte THEN '' ELSE dbo.fduFechaATexto(tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') END AS Cancelacion, 
                      dbo.fduFechaATexto(dbo.tINTFPeriodo.Corte, 'DDMMAAAA') AS Reporte, SUBSTRING(tINTFCuenta.CreditoMaximo, 5, 20) AS Maximo, 
                      RTRIM(LTRIM(STR(ISNULL(ROUND(dbo.tCsCartera.SaldoCapital + dbo.tCsCartera.SaldoInteresCorriente + dbo.tCsCartera.SaldoINVE + dbo.tCsCartera.SaldoINPE, 0), 
                      0), 18, 0))) AS SaldoActual, tINTFCuenta.LimiteCredito, RTRIM(LTRIM(STR(CASE WHEN round(Vencido.SaldoVencido, 0) IS NULL 
                      THEN 0 ELSE round(Vencido.SaldoVencido, 0) END))) AS SaldoVencido, ISNULL(dbo.tCsCartera.CuotaActual - dbo.tCsCartera.NroCuotasPagadas, 
                      SUBSTRING(tINTFCuenta.PagosVencidos, 5, 10)) AS PagosVencidos, CASE WHEN tCsPadronCarteraDet.Cancelacion > Corte THEN ISNULL(dbo.tCsBuroMOP.MOP, 
                      SUBSTRING(tINTFCuenta.MOP, 5, 2)) WHEN tCsPadronCarteraDet.Cancelacion IS NULL THEN ISNULL(dbo.tCsBuroMOP.MOP, SUBSTRING(tINTFCuenta.MOP, 5, 2)) 
                      ELSE '01' END AS MOP, '' AS Observacion
FROM         dbo.tCsPagoDet with(nolock) INNER JOIN
                      dbo.tINTFPeriodo ON dbo.tCsPagoDet.Fecha = dbo.tINTFPeriodo.Corte INNER JOIN
                          (SELECT     Periodo, CodPrestamo, Responsabilidad, TipoCuenta, TipoContrato, UnidadMonetaria, NumeroPagos, FrecuenciaPagos, MontoPagar, Apertura, 
                                                   Disposicion, MAX(CreditoMaximo) AS CreditoMaximo, LimiteCredito, PagosVencidos, MOP
                            FROM          tINTFCuenta
                            GROUP BY Periodo, CodPrestamo, Responsabilidad, TipoCuenta, TipoContrato, UnidadMonetaria, NumeroPagos, FrecuenciaPagos, MontoPagar, Apertura, 
                                                   Disposicion, LimiteCredito, PagosVencidos, MOP) tINTFCuenta ON dbo.tINTFPeriodo.Periodo = tINTFCuenta.Periodo AND 
                      dbo.tCsPagoDet.CodPrestamo = SUBSTRING(tINTFCuenta.CodPrestamo, 5, 25) INNER JOIN
                      dbo.tCsPadronCarteraDet with(nolock) ON dbo.tCsPagoDet.CodPrestamo = dbo.tCsPadronCarteraDet.CodPrestamo LEFT OUTER JOIN
                          (SELECT     Fecha, CodPrestamo, ROUND(SUM(MontoDevengado - MontoPagado - MontoCondonado), 0) AS SaldoVencido
                            FROM          (SELECT     Fecha, CodPrestamo, MontoDevengado, MontoPagado, MontoCondonado, 
                                                                           CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
                                                    FROM          tcsplancuotas with(nolock)
                                                    WHERE      fecha IN
                                                                               (SELECT     corte
                                                                                 FROM          tintfperiodo) AND (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))) 
                                                   Vencido
                            WHERE      (DiasAtrCuota = 1)
                            GROUP BY Fecha, CodPrestamo) Vencido ON dbo.tCsPagoDet.CodPrestamo = Vencido.CodPrestamo COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
                      dbo.tCsCartera with(nolock) ON dbo.tINTFPeriodo.Corte = dbo.tCsCartera.Fecha AND dbo.tCsPagoDet.CodPrestamo = dbo.tCsCartera.CodPrestamo LEFT OUTER JOIN
                      dbo.tCsBuroMOP ON dbo.tCsCartera.NroDiasAtraso >= dbo.tCsBuroMOP.Inicio AND dbo.tCsCartera.NroDiasAtraso <= dbo.tCsBuroMOP.Fin
WHERE     (dbo.tINTFPeriodo.Activo = 1)

GO