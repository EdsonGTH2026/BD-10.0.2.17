SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE procedure [dbo].[pRptFDetalleAhorros] 
@Fecha smalldatetime 
as
SELECT     a.Fecha, a.CodCuenta, a.FraccionCta, a.Renovado, a.CodOficina, o.DescOficina AS Oficina, a.CodProducto, p.Nombre AS Producto, a.CodMoneda, 
                      m.DescMoneda AS Moneda, a.CodUsuario, u.Nombre AS Cliente, a.NomCuenta, a.FechaApertura, a.FechaVencimiento, a.TasaInteres, a.FechaUltMov, 
                      a.TipoCambioFijo, a.SaldoCuenta, a.SaldoMonetizado, a.MontoInteres, a.IntAcumulado, a.MontoInteresCapitalizado, a.MontoBloqueado, 
                      a.MontoRetenido, a.idEstadoCta, ec.Descripcion AS Estado
FROM         tCsAhorros a INNER JOIN
                      tClMonedas m ON a.CodMoneda = m.CodMoneda INNER JOIN
                      tClOficinas o ON a.CodOficina = o.CodOficina LEFT OUTER JOIN
                      TAhProductos p ON a.CodProducto = p.idProducto LEFT OUTER JOIN
                          (SELECT     cl.CodOficina OfiUsuario, cl.CodUsuario, MAX(NombreCompleto) Nombre, cl.CodDocIden, cl.DI, --MAX(UsCodUsSuper) CodSbs, 
                                                   MAX(LabCodActividad) CodActividad, MAX(CodUbigeoDirFamPri) Ubigeo, MAX(cl.direcciondirfampri) Direccion, MAX(cl.telefonodirfampri) 
                                                   Telefono
                            FROM          tCsClientes cl
                            GROUP BY cl.codoficina, cl.CodUsuario, cl.CodDocIden, cl.DI) u ON a.CodUsuario = u.CodUsuario AND a.CodOficina = u.OfiUsuario LEFT OUTER JOIN
                      tAhClEstadoCuenta ec ON a.idEstadoCta = ec.IdEstadoCta
WHERE     (a.Fecha =  @Fecha) AND (a.idEstadoCta NOT IN ('cc', 'ce')) AND (a.SaldoCuenta + a.FondoConfirmar > 0)
GO