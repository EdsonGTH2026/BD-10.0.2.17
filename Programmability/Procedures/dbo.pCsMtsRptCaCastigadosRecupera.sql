SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsMtsRptCaCastigadosRecupera] @Fecha smalldatetime, @FechaIni smalldatetime AS
SELECT     REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS oficina, 
                      SUM(tCsTransaccionDiaria.MontoCapitalTran) AS CAPITAL, 
                      SUM(tCsTransaccionDiaria.MontoInteresTran + tCsTransaccionDiaria.MontoINVETran + tCsTransaccionDiaria.MontoINPETran) AS INTERESES
FROM         tCsCartera INNER JOIN
                      tCsTransaccionDiaria ON tCsCartera.CodPrestamo = tCsTransaccionDiaria.CodigoCuenta INNER JOIN
                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina
WHERE     (tCsTransaccionDiaria.CodSistema = 'CA') AND (tCsCartera.Fecha = @Fecha)  AND 
                      (tCsTransaccionDiaria.Fecha <= @Fecha) AND (tCsCartera.Estado = 'CASTIGADO') and tCsTransaccionDiaria.descripciontran<>'Desembolso'
GROUP BY REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina

--AND (tCsTransaccionDiaria.Fecha >= @FechaIni)
GO