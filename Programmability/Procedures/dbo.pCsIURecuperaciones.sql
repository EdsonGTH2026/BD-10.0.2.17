SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIURecuperaciones] @CodPrestamo varchar(25), @CodUsuario varchar(25)  AS

SELECT     tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.TranHora + ':' + tCsTransaccionDiaria.TranMinuto + ':' + tCsTransaccionDiaria.TranSegundo AS Hora,
                       tClOficinas.NomOficina, tCsTransaccionDiaria.NroTransaccion, tCsTransaccionDiaria.TipoTransacNivel1 AS Tipo, 
                      tCsTransaccionDiaria.TipoTransacNivel2 AS Forma, tCsTransaccionDiaria.Extornado, tCsTransaccionDiaria.DescripcionTran, Cajeros.NomCajero, 
                      tCsTransaccionDiaria.MontoCapitalTran, tCsTransaccionDiaria.MontoInteresTran, tCsTransaccionDiaria.MontoINPETran, 
                      tCsTransaccionDiaria.MontoOtrosTran, tCsTransaccionDiaria.MontoTotalTran, ISNULL(Detpago.RecUsuCap, 0) AS RecUsuCap, 
                      ISNULL(Detpago.RecUsuInte, 0) AS RecUsuInte, ISNULL(Detpago.RecUsuInpe, 0) AS RecUsuInpe, ISNULL(Detpago.RecUsuOtros, 0) 
                      AS RecUsuOtros
FROM         tCsTransaccionDiaria with(nolock) INNER JOIN
                      tClOficinas with(nolock) ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
                          (SELECT     Fecha, CodOficina, CodPrestamo, SecPago, SUM(RecUsuCap) AS RecUsuCap, SUM(RecUsuInte) AS RecUsuInte, SUM(RecUsuInpe) 
                                                   AS RecUsuInpe, SUM(RecUsuOtros) AS RecUsuOtros
                            FROM          (SELECT     Fecha, CodOficina, CodPrestamo, SecPago, CASE codconcepto WHEN 'CAPI' THEN MontoPagado ELSE 0 END AS RecUsuCap, 
                                                                           CASE codconcepto WHEN 'INTE' THEN MontoPagado ELSE 0 END AS RecUsuInte, 
                                                                           CASE codconcepto WHEN 'INPE' THEN MontoPagado ELSE 0 END AS RecUsuInpe, CASE WHEN codconcepto NOT IN ('CAPI', 
                                                                           'INTE', 'INPE') THEN MontoPagado ELSE 0 END AS RecUsuOtros
                                                    FROM          tCsPagoDet with(nolock)
                                                    WHERE      (Extornado = 0) AND (CodUsuario = @CodUsuario)) A
                            GROUP BY Fecha, CodOficina, CodPrestamo, SecPago) Detpago ON tCsTransaccionDiaria.Fecha = Detpago.Fecha AND 
                      tCsTransaccionDiaria.CodOficina = Detpago.CodOficina COLLATE Modern_Spanish_CI_AI AND 
                      tCsTransaccionDiaria.CodigoCuenta = Detpago.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
                      tCsTransaccionDiaria.NroTransaccion = Detpago.SecPago LEFT OUTER JOIN
                          (SELECT     codusuario, nombrecompleto NomCajero
                            FROM          tCsPadronClientes with(nolock)) Cajeros ON tCsTransaccionDiaria.CodCajero = Cajeros.codusuario
WHERE     (tCsTransaccionDiaria.CodSistema = 'ca') AND (tCsTransaccionDiaria.CodigoCuenta = @CodPrestamo)
ORDER BY tCsTransaccionDiaria.Fecha, 
                      CAST(tCsTransaccionDiaria.TranHora + ':' + tCsTransaccionDiaria.TranMinuto + ':' + tCsTransaccionDiaria.TranSegundo AS smalldatetime)
GO