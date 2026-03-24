SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsMtsRptCaDatosMora] @Fecha smalldatetime AS
SELECT     oficina, SUM(SaldoCartera) AS SaldoCartera, COUNT(DISTINCT NroCreditos) AS NroCreditos, SUM(SaldoCarteraVenc) AS SaldoCarteraVenc, 
                      SUM(IndSaldo) AS IndSaldo, SUM(GruSaldo) AS GruSaldo, SUM(PreSaldo) AS PreSaldo, COUNT(IndCreditos) AS IndCreditos, 
                      COUNT(DISTINCT GruCreditos) AS GruCreditos, COUNT(PreCreditos) AS PreCreditos
FROM         (SELECT     REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                                              tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                               AS SaldoCartera, 
                                              CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.CodPrestamo ELSE (CASE WHEN NumReprog > 0 THEN tCsCarteraDet.CodPrestamo
                                               ELSE NULL END) END AS NroCreditos, 
                                              CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido +
                                               tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido ELSE (CASE WHEN NumReprog > 0 THEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente
                                               + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido ELSE 0 END) 
                                              END AS SaldoCarteraVenc, 
                                              CASE tCaProducto.tecnologia WHEN 1 THEN CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente
                                               + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido ELSE (CASE WHEN NumReprog > 0 THEN
                                               tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                               ELSE 0 END) END ELSE 0 END AS IndSaldo, 
                                              CASE tCaProducto.tecnologia WHEN 2 THEN CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente
                                               + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido ELSE (CASE WHEN NumReprog > 0 THEN
                                               tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                               ELSE 0 END) END ELSE 0 END AS GruSaldo, 
                                              CASE tCaProducto.tecnologia WHEN 3 THEN CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente
                                               + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido ELSE (CASE WHEN NumReprog > 0 THEN
                                               tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                               ELSE 0 END) END ELSE 0 END AS PreSaldo, 
                                              CASE tCaProducto.tecnologia WHEN 1 THEN CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.CodPrestamo ELSE (CASE WHEN
                                               NumReprog > 0 THEN tCsCarteraDet.CodPrestamo ELSE NULL END) END ELSE NULL END AS IndCreditos, 
                                              CASE tCaProducto.tecnologia WHEN 2 THEN CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.CodPrestamo ELSE (CASE WHEN
                                               NumReprog > 0 THEN tCsCarteraDet.CodPrestamo ELSE NULL END) END ELSE NULL END AS GruCreditos, 
                                              CASE tCaProducto.tecnologia WHEN 3 THEN CASE WHEN tCsCartera.NroDiasAtraso > 0 THEN tCsCarteraDet.CodPrestamo ELSE (CASE WHEN
                                               NumReprog > 0 THEN tCsCarteraDet.CodPrestamo ELSE NULL END) END ELSE NULL END AS PreCreditos
                       FROM          tCsCartera INNER JOIN
                                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                              tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina INNER JOIN
                                              tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto
                       WHERE      (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Estado <> 'castigado')) A
GROUP BY oficina
GO