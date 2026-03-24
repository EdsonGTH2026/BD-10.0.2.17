SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUMovimientosAH] @CodCuenta varchar(50), @Fraccion varchar(5), @Renovado varchar(5) AS
SELECT     tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.TranHora + ':' + tCsTransaccionDiaria.TranMinuto + ':' + tCsTransaccionDiaria.TranSegundo AS Hora, 
                      tClOficinas.NomOficina, tCsTransaccionDiaria.NroTransaccion, tCsTransaccionDiaria.TipoTransacNivel1 AS Tipo, tCsTransaccionDiaria.TipoTransacNivel2 AS Forma, 
                      tCsTransaccionDiaria.Extornado, tCsTransaccionDiaria.DescripcionTran, Cajeros.NomCajero, tCsTransaccionDiaria.MontoTotalTran
FROM         tCsTransaccionDiaria with(nolock) INNER JOIN
                      tClOficinas with(nolock) ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
                          (SELECT     codusuario, nombrecompleto NomCajero
                            FROM          tCsPadronClientes with(nolock)) Cajeros ON tCsTransaccionDiaria.CodCajero = Cajeros.codusuario
WHERE     (tCsTransaccionDiaria.CodSistema = 'AH') AND (tCsTransaccionDiaria.CodigoCuenta = @CodCuenta) AND (tCsTransaccionDiaria.FraccionCta = @Fraccion) AND 
                      (tCsTransaccionDiaria.Renovado = @Renovado)
ORDER BY tCsTransaccionDiaria.Fecha, 
                      CAST(tCsTransaccionDiaria.TranHora + ':' + tCsTransaccionDiaria.TranMinuto + ':' + tCsTransaccionDiaria.TranSegundo AS smalldatetime)
GO