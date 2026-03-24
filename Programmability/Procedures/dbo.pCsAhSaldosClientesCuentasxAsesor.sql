SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsAhSaldosClientesCuentasxAsesor] @Fecha smalldatetime AS
SELECT     Fecha, NomOficina, CodAsesor, Asesor, CodProducto, NombreProducto, COUNT(DISTINCT codusuario) AS NroClientes, COUNT(CodCuenta) 
                      AS NroCuentas, SUM(SaldoCuenta) AS SaldoCuenta, SUM(MontoInteres) AS MontoInteres, SUM(MontoInteresCapitalizado) 
                      AS MontoInteresCapitalizado, SUM(MontoBloqueado) AS MontoBloqueado, SUM(MontoRetenido) AS MontoRetenido
FROM         (SELECT     tCsAhorros.Fecha, tClOficinas.NomOficina, Asesores.NombreCompleto AS Asesor, tCsAhorros.codusuario, tCsAhorros.CodCuenta, 
                                              tCsAhorros.CodProducto, tAhProductos.Nombre AS NombreProducto, tCsAhorros.SaldoCuenta, tCsAhorros.MontoInteres, 
                                              tCsAhorros.MontoInteresCapitalizado, tCsAhorros.MontoBloqueado, tCsAhorros.MontoRetenido, tCsAhorros.CodAsesor
                       FROM          tCsAhorros LEFT OUTER JOIN
                                              tCsPadronClientes Asesores ON tCsAhorros.CodAsesor = Asesores.CodUsuario LEFT OUTER JOIN
                                              tCsPadronClientes ON tCsAhorros.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                                              tAhProductos ON tCsAhorros.CodProducto = tAhProductos.idProducto LEFT OUTER JOIN
                                              tClOficinas ON tCsAhorros.CodOficina = tClOficinas.CodOficina
                       WHERE      (tCsAhorros.Fecha = @Fecha)) a
GROUP BY Fecha, NomOficina, Asesor, CodProducto, NombreProducto, CodAsesor
GO