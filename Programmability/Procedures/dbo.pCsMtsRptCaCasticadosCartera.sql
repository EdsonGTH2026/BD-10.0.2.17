SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsMtsRptCaCasticadosCartera] @Fecha smalldatetime AS
SELECT     oficina, COUNT(distinct CodUsuario) AS CLIENTES, SUM(SaldoCartera) AS [CAPITAL], SUM([CTAS ORDEN]) 
                      AS [CTAS ORDEN], SUM(OtrosCargos)  OtrosCargos
FROM         (SELECT     REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                                              tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido
                                               AS SaldoCartera, tCsCarteradet.CodUsuario, 
                                              tCsCarteraDet.SaldoCapital + tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio AS 'CAPITAL', 
                                              tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden  AS 'CTAS ORDEN', tCsCarteraDet.OtrosCargos
                       FROM          tCsCartera INNER JOIN
                                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                                              tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina INNER JOIN
                                              tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto
                       WHERE      (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Estado = 'castigado')) A
GROUP BY oficina
GO