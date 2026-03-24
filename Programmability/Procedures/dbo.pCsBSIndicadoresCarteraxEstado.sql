SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsBSIndicadoresCarteraxEstado] @Fecha smalldatetime AS
SELECT     estado, montodesembolso, saldocartera, recuperacion, estimacion, moragral, moracnbv
FROM         (SELECT     tCPClEstado.Estado, SUM(tCsBsCartera.MontoDesembolso) AS MontoDesembolso, SUM(tCsBsCartera.SaldoCartera) AS SaldoCartera, 
                                              SUM(tCsBsCartera.Recuperacion) AS Recuperacion, SUM(tCsBsCartera.Estimacion) AS Estimacion, SUM(tCsBsCartera.Saldo0Dias) 
                                              / SUM(tCsBsCartera.SaldoCartera) * 100 AS MoraGral, SUM(tCsBsCartera.Saldo90Dias) / SUM(tCsBsCartera.SaldoCartera) 
                                              * 100 AS MoraCNBV
                       FROM          tCPClEstado RIGHT OUTER JOIN
                                              tClUbigeo ON tCPClEstado.CodEstado = tClUbigeo.CodEstado RIGHT OUTER JOIN
                                              tClOficinas ON tClUbigeo.CodUbiGeo = tClOficinas.CodUbiGeo RIGHT OUTER JOIN
                                              tCsBsCartera ON tClOficinas.CodOficina = tCsBsCartera.CodOficina
                       WHERE      (tCsBsCartera.Fecha = @Fecha)
                       GROUP BY tCsBsCartera.Fecha, tCPClEstado.Estado) A
GO