SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsAhRptSaldosAhorrosResumen]  @Fecha smalldatetime  AS
SELECT     REPLICATE('0', 2 - DATALENGTH(tClOficinas.CodOficina)) + tClOficinas.CodOficina + ' ' + tClOficinas.NomOficina AS Oficina, 
                      COUNT(tCsAhorros.CodCuenta) AS NroCuentas, SUM(tCsAhorros.SaldoCuenta) AS SaldoCuenta, SUM(tCsAhorros.InteresCalculado) AS IntDia, 
                      SUM(tCsAhorros.IntAcumulado) AS SaldoInt
FROM         tCsAhorros with(nolock) INNER JOIN
                      tClOficinas with(nolock) ON tCsAhorros.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tAhProductos with(nolock) ON tCsAhorros.CodProducto = tAhProductos.idProducto INNER JOIN
                      tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd
WHERE     (tCsAhorros.Fecha = @Fecha)
GROUP BY tClOficinas.NomOficina, tClOficinas.CodOficina
ORDER BY CAST( tClOficinas.CodOficina AS int)
GO