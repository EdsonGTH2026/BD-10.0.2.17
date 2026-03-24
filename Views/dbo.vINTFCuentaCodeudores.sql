SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vINTFCuentaCodeudores]
AS
SELECT     VISTA.CodPrestamo, VISTA.CodUsuario, dbo.vINTFCabecera.ClaveUsuario, dbo.vINTFCabecera.NombreUsuario, 
	        --RESPONSABILIDAD:
                      CASE Tipo WHEN 'Aval' THEN 'C' 
			WHEN 'Codeudor' THEN 'J' 
			ELSE dbo.tCaClTecnologia.Responsabilidad END AS Responsabilidad,
	         'I' AS TipoCuenta, 
                      dbo.tCaProducto.TipoContrato, CASE WHEN tipo = 'Aval' THEN tClMonedas_1.INTF ELSE dbo.tClMonedas.INTF END AS UnidadMonetaria, 
                      CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo, 
                      CASE WHEN tipo = 'Aval' THEN tCsCartera.NroCuotas ELSE tCsCartera_1.NroCuotas END AS NumeroPagos, 
                      CASE WHEN Tipo = 'Aval' THEN tCaClModalidadPlazo_1.INTF ELSE dbo.tCaClModalidadPlazo.INTF END AS FrecuenciaPagos, 
                      CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE MontoPagar.MontoPagar END AS MontoPagar, 
                      CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                      ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Apertura, 
                      CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaUltimoMovimiento, 'DDMMAAAA') 
                      ELSE dbo.fduFechaATexto(tCsCartera_1.FechaUltimoMovimiento, 'DDMMAAAA') END AS UltimoPago, 
                      CASE WHEN Tipo = 'Aval' THEN dbo.fduFechaATexto(tCsCartera.FechaDesembolso, 'DDMMAAAA') 
                      ELSE dbo.fduFechaATexto(tCsCartera_1.FechaDesembolso, 'DDMMAAAA') END AS Disposicion, 
                      CASE WHEN Tipo = 'Cancelados' THEN dbo.fduFechaATexto(dbo.tCsPadronCarteraDet.Cancelacion, 'DDMMAAAA') ELSE '' END AS Cancelacion, 
                      dbo.vINTFCabecera.FechaReporte AS Reporte, CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia, 
                      CreditoMaximo.CreditoMaximo, 
                      CASE WHEN Tipo = 'Cancelados' THEN 0 ELSE ROUND(dbo.tCsCartera.SaldoCapital + dbo.tCsCartera.SaldoInteresCorriente + dbo.tCsCartera.SaldoINVE
                       + dbo.tCsCartera.SaldoINPE, 0) END AS SaldoActual, '' AS LimiteCredito, 
                      CASE When dbo.tCsCartera.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido, 
                      CASE WHEN tipo = 'Cancelados' THEN 0 ELSE dbo.tCsCartera.CuotaActual - dbo.tCsCartera.NroCuotasPagadas END AS PagosVencidos, 
	        ----MOP: Manner Of Payment
                      CASE 
		WHEN 	dbo.fdufechaatexto(tCsCartera.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(VISTA.Fecha, 'AAAAMM') AND 
                     		 tCsCartera.FechaDesembolso = dbo.tCsCartera.FechaUltimoMovimiento THEN '00' 
		WHEN 	Tipo = 'Cancelados' Then '01' 
		WHEN tCsCartera.Judicial = 'Judicial' and dbo.tCsBuroMOP.MOP = '01' Then '02'
		WHEN tCsCartera.Judicial = 'Judicial' Then dbo.tCsBuroMOP.MOP
		WHEN 	tCscartera.Cartera = 'CASTIGADA' Then '97'
			--WHEN dbo.tCsCartera.TipoReprog <> 'SINRE' THEN '02'
		ELSE 	dbo.tCsBuroMOP.MOP

                       END AS MOP, '' AS HistoricoPagos, 
	         --OBSERVACION
	        	 CASE 	WHEN tCsCartera.Judicial = 'Judicial' Then 'SG' 
			WHEN tCscartera.Cartera = 'CASTIGADA' THEN 'UP' 
			ELSE '' END AS Observacion, 
		Historico.PagosReportados, 
                      	Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta, 
                      	'FIN' AS FinSegmento
FROM         (SELECT     CodPrestamo, Round(SUM(MontoCuota), 0) AS MontoPagar
                       FROM          tCsPadronPlanCuotas with(nolock)
                       WHERE      (SecCuota = 1)
                       GROUP BY CodPrestamo) MontoPagar RIGHT OUTER JOIN
                          (SELECT     CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) 
                                                   AS MOP04, SUM(MOP05) AS MOP05
                            FROM          (SELECT     CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01, 
                                                                           CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03, 
                                                                           CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05
                                                    FROM          (SELECT DISTINCT 
                      tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodUsuario, tCsPadronPlanCuotas.NumeroPlan, tCsPadronPlanCuotas.SecCuota, tCsBuroMOP.MOP
FROM         tCsPadronPlanCuotas with(nolock) INNER JOIN
                      vINTFCabecera ON tCsPadronPlanCuotas.FechaVencimiento <=
                          (SELECT     Corte
                            FROM          vINTFCabecera) INNER JOIN
                      tCsBuroMOP ON tCsPadronPlanCuotas.DiasAtrCuota >= tCsBuroMOP.Inicio AND tCsPadronPlanCuotas.DiasAtrCuota <= tCsBuroMOP.Fin
) Datos) Datos
                            GROUP BY CodPrestamo) Historico RIGHT OUTER JOIN
                      vINTFNombreCodeudores VISTA LEFT OUTER JOIN
                          (SELECT     Fecha, CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado), 0) AS SaldoVencido
                            FROM          (SELECT     Fecha, CodPrestamo,  MontoDevengado, MontoPagado, MontoCondonado, CASE WHEN DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota
                                                    FROM          tCsMesPlanCuotas with(nolock)
                                                    WHERE      (CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE')) AND (EstadoConcepto NOT IN ('ANULADO', 'CANCELADO'))) Vencido
                            WHERE      (DiasAtrCuota = 1)
                            GROUP BY Fecha, CodPrestamo) Vencido ON VISTA.Fecha = Vencido.Fecha AND 
                      VISTA.CodPrestamo = Vencido.CodPrestamo COLLATE Modern_Spanish_CI_AI ON 
                      Historico.CodPrestamo COLLATE Modern_Spanish_CI_AI = VISTA.CodPrestamo LEFT OUTER JOIN
                          (SELECT     Datos.CodUsuario, Round(MAX(Datos.MontoDesembolso), 0) AS CreditoMaximo
                            FROM          (SELECT     tCsPadronCarteraDet.CodUsuario, tCsCartera.FechaDesembolso, tCsCartera.MontoDesembolso
                                                    FROM          tCsPadronCarteraDet with(nolock) INNER JOIN
                                                                           tCsCarteraDet with(nolock) ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                                                                           tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario AND 
                                                                           tCsPadronCarteraDet.FechaCorte = tCsCarteraDet.Fecha INNER JOIN
                                                                           tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo) 
                                                   Datos INNER JOIN
                                                   vINTFCabecera ON Datos.FechaDesembolso <= vINTFCabecera.Corte
                            GROUP BY Datos.CodUsuario) CreditoMaximo ON VISTA.CodUsuario = CreditoMaximo.CodUsuario LEFT OUTER JOIN
                      tCaProducto ON SUBSTRING(VISTA.CodPrestamo, 5, 3) = tCaProducto.CodProducto ON 
                      MontoPagar.CodPrestamo = VISTA.CodPrestamo LEFT OUTER JOIN
                      tCaClModalidadPlazo tCaClModalidadPlazo_1 RIGHT OUTER JOIN
                      tCsCartera with(nolock) ON tCaClModalidadPlazo_1.ModalidadPlazo = tCsCartera.ModalidadPlazo LEFT OUTER JOIN
                      tClMonedas tClMonedas_1 ON tCsCartera.CodMoneda = tClMonedas_1.CodMoneda LEFT OUTER JOIN
                      tCsBuroMOP ON tCsCartera.NroDiasAtraso >= tCsBuroMOP.Inicio AND tCsCartera.NroDiasAtraso <= tCsBuroMOP.Fin ON 
                      VISTA.Fecha = tCsCartera.Fecha AND VISTA.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN
                      tClMonedas RIGHT OUTER JOIN
                      tCsCartera tCsCartera_1 with(nolock) INNER JOIN
                      tCsBuroMOP tCsBuroMOP_1 ON tCsCartera_1.NroDiasAtraso >= tCsBuroMOP_1.Inicio AND 
                      tCsCartera_1.NroDiasAtraso <= tCsBuroMOP_1.Fin LEFT OUTER JOIN
                      tCaClModalidadPlazo ON tCsCartera_1.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo ON 
                      tClMonedas.CodMoneda = tCsCartera_1.CodMoneda RIGHT OUTER JOIN
                      tCsPadronCarteraDet with(nolock) ON tCsCartera_1.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      tCsCartera_1.Fecha = tCsPadronCarteraDet.FechaCorte ON VISTA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      VISTA.CodUsuario = tCsPadronCarteraDet.CodUsuario LEFT OUTER JOIN
                          (SELECT     Filtro.Fecha, Datos.Codigo, Filtro.Garantia AS ImporteAvaluo, tGaClTipoGarantias.DescGarantia
                            FROM          (SELECT     Fecha, Codigo, MAX(Garantia) AS Garantia
                                                    FROM          (SELECT     Fecha, Codigo, TipoGarantia, Round(SUM(moComercial), 0) AS Garantia
                                                                            FROM          tCsMesGarantias tCsGarantias with(nolock)
                                                                            WHERE      (Estgarantia NOT IN ('INACTIVO'))
                                                                            GROUP BY Fecha, Codigo, TipoGarantia) Datos
                                                    GROUP BY Fecha, Codigo) Filtro INNER JOIN
                                                       (SELECT     Fecha, Codigo, TipoGarantia, Round(SUM(mocomercial), 0) AS Garantia
                                                         FROM          tCsMesGarantias tCsGarantias with(nolock)
                                                         WHERE      (Estgarantia NOT IN ('INACTIVO'))
                                                         GROUP BY FEcha, Codigo, TipoGarantia) Datos ON Filtro.Codigo = Datos.Codigo AND Filtro.Garantia = Datos.Garantia AND 
                                                   Filtro.Fecha = Datos.Fecha LEFT OUTER JOIN
                                                   tGaClTipoGarantias ON Datos.TipoGarantia = tGaClTipoGarantias.TipoGarantia) Avaluo ON VISTA.Fecha = Avaluo.Fecha AND 
                      VISTA.CodPrestamo = Avaluo.Codigo LEFT OUTER JOIN
                      tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia CROSS JOIN
                      vINTFCabecera



GO