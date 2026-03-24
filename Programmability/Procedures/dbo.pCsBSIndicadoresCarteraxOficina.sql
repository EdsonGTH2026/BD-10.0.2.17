SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsBSIndicadoresCarteraxOficina] @Fecha smalldatetime  AS
SELECT     estado, oficina, montodesembolso, saldocartera, recuperacion, estimacion, moragral, moracnbv
FROM         (SELECT     tCsBsCartera.Fecha, tCPClEstado.Estado, '1' + REPLICATE('0', 2 - DATALENGTH(tCsBsCartera.CodOficina)) 
                                              + tCsBsCartera.CodOficina + ' - ' + tClOficinas.NomOficina AS Oficina, SUM(tCsBsCartera.MontoDesembolso) AS MontoDesembolso, 
                                              SUM(tCsBsCartera.SaldoCartera) AS SaldoCartera, SUM(tCsBsCartera.Recuperacion) AS Recuperacion, SUM(tCsBsCartera.Estimacion) 
                                              AS Estimacion, SUM(tCsBsCartera.Saldo0Dias) / SUM(tCsBsCartera.SaldoCartera) * 100 AS MoraGral, SUM(tCsBsCartera.Saldo90Dias) 
                                              / SUM(tCsBsCartera.SaldoCartera) * 100 AS MoraCNBV
                       FROM          tCPClEstado RIGHT OUTER JOIN
                                              tClUbigeo ON tCPClEstado.CodEstado = tClUbigeo.CodEstado RIGHT OUTER JOIN
                                              tClOficinas ON tClUbigeo.CodUbiGeo = tClOficinas.CodUbiGeo RIGHT OUTER JOIN
                                              tCsBsCartera ON tClOficinas.CodOficina = tCsBsCartera.CodOficina
                       WHERE      (tCsBsCartera.Fecha = @Fecha)
                       GROUP BY tCsBsCartera.Fecha, tCsBsCartera.CodOficina, tClOficinas.NomOficina, tCPClEstado.Estado) A
GO