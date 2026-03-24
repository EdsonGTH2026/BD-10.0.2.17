SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsBSIndicadoresCartera] @Fecha smalldatetime AS
SELECT montodesembolso,saldocartera,recuperacion,estimacion,moragral,moracnbv FROM ( 
SELECT Fecha, SUM(MontoDesembolso) AS MontoDesembolso, SUM(SaldoCartera) AS SaldoCartera, 
SUM(Saldo0Dias) AS Saldo0Dias, SUM(Saldo90Dias) AS Saldo90Dias, SUM(Recuperacion) AS Recuperacion, 
SUM(Estimacion) AS Estimacion, SUM(Saldo0Dias) / SUM(SaldoCartera) * 100 AS MoraGral, 
SUM(Saldo90Dias) / SUM(SaldoCartera) * 100 AS MoraCNBV 
FROM tCsBsCartera WHERE (Fecha = @Fecha) 
GROUP BY Fecha) Generales
GO