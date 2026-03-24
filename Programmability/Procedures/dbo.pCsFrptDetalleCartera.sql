SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE procedure [dbo].[pCsFrptDetalleCartera]

@Fecha smalldatetime   
as
SELECT     c.Fecha, c.CodPrestamo, c.CodSolicitud, c.CodOficina, c.CodProducto, c.CodAsesor, ISNULL(c.CodGrupo, 1) AS GrupoSolidario, tClFondos.DescFondo, 
                      tClFondos.EsActivo, a.NomAsesor AS Sectorista, o.DescOficina, c.CodUsuario, c.CodGrupo, c.CodFondo, c.CodTipoCredito, c.CodDestino, 
                      c.NivelAprobacion, c.Estado, c.TipoReprog, c.NroDiasCredito, c.ModalidadPlazo, c.NroCuotas, c.NroCuotasPagadas, c.NroCuotasPorPagar, 
                      c.NroDiasPagocuota1, c.NrodiasEntreCuotas, c.FechaSolicitud, c.FechaAprobacion, c.FechaDesembolso, c.FechaVencimiento, c.MontoDesembolso, 
                      c.SaldoCapital, c.CodMoneda, c.NumReprog, c.FechaReprog, c.PrestamoReprog, c.SaldoCapitalMonetizado, SaldoMontoConcecional = 0, 
                      c.NroDiasAtraso, c.SaldoCapitalAtrasado, c.SaldoInteresCorriente, c.SaldoINVE, c.SaldoINPE, c.SaldoEnMora, c.CargoMora, c.CodRuta, c.Calificacion, 
                      c.ProvisionCapital, c.ProvisionInteres, c.GarantiaLiquidaMonetizada, c.GarantiaPreferidaMonetizada, c.GarantiaMuyRapidaRealizacion, 
                      c.TotalGarantia, c.FechaUltimoMovimiento, c.TasaIntCorriente, c.TasaINPE, c.TipoCalificacion, c.ComisionDesembolso, c.SaldoINTEVig, 
                      c.SaldoINPEVig, c.SaldoINTESus, c.SaldoINPESus, ca.NemCalificacion, ca.DescCalificacion, pr.DescDestino, pr.PadreDestino
FROM         tCsCartera c INNER JOIN
                      tCaClCalificacion ca ON c.Calificacion = ca.CodCalificacion INNER JOIN
                      tClFondos ON c.CodFondo = tClFondos.CodFondo LEFT OUTER JOIN
                      tClOficinas o ON c.CodOficina = o.CodOficina LEFT OUTER JOIN
                      vCsProductosCaja pr ON c.CodDestino = pr.Nieto LEFT OUTER JOIN
                          (SELECT DISTINCT CodAsesor, NomAsesor
                            FROM          tCsAsesores) a ON c.CodAsesor = a.CodAsesor

WHERE     (c.Fecha = @Fecha)
GO