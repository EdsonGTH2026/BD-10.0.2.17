SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE  [dbo].[pCsAhCumpleañosAhorristas] @fecIni  smalldatetime, @fecFin  smalldatetime,  @oficina varchar(100)  as

DECLARE @Fecha smalldatetime

select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

SELECT     tCsAhorros.Fecha, tCsAhorros.CodOficina, tClOficinas.NomOficina, tClOficinas.DescOficina, tCsAhorros.CodProducto, tAhProductos.Abreviatura, 
                      tAhClTipoProducto.DescTipoProd, tAhClFormaManejo.Descripcion, tCsAhorros.CodUsuario, tCsPadronClientes.NombreCompleto, tCsAhorros.CodCuenta, 
                      tCsAhorros.Renovado, tCsAhorros.CodMoneda, tCsAhorros.FechaApertura, tCsAhorros.FechaVencimiento, tCsAhorros.FechaCierre, tCsAhorros.TasaInteres, 
                      tCsAhorros.FechaUltMov, tCsAhorros.SaldoCuenta, tCsAhorros.MontoInteres, tCsAhorros.IntAcumulado, tCsAhorros.MontoInteresCapitalizado, 
                      tCsAhorros.MontoBloqueado, tCsAhorros.MontoRetenido, tCsAhorros.InteresCalculado, tCsAhorros.Plazo, tCsAhorros.Lucro, tCsAhorros.CodAsesor, 
                      tCsPadronClientes_1.NombreCompleto AS AsesordeAhorro, tCsPadronClientes.FechaIngreso, tCsPadronClientes.FechaNacimiento, tCsPadronClientes.CodEstadoCivil, 
                      tCsPadronClientes.CodConyuge, tCsPadronClientes.Sexo, tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.DireccionDirFamPri, 
                      tCsPadronClientes.TelefonoDirFamPri, tCsAhorros.FechaUltCapitalizacion, tCsAhorros.idEstadoCta, tCsAhorros.NomCuenta, 
                      tAhClEstadoCuenta.Descripcion AS EstadoCTa, tCsAhorros.FondoConfirmar, tCsAhorros.Observacion, tCsAhorros.EnGarantia, tCsAhorros.Garantia, 
                      tCsAhorros.CuentaPreferencial, tCsAhorros.CuentaReservada, tCsAhorros.CodCuentaAnt, tCsAhorros.FechaCambioEstado, tCsAhorros.FechaInactivacion, 
                      tCsAhorros.NroSolicitud, tAhClTipoInteres.Descripcion AS TipoInteresExpr1, tAhClTipoInteres.Estado
FROM         tCsAhorros INNER JOIN
                      tClOficinas ON tCsAhorros.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tCsPadronClientes ON tCsAhorros.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                      tCsPadronClientes tCsPadronClientes_1 ON tCsAhorros.CodAsesor = tCsPadronClientes_1.CodUsuario INNER JOIN
                      tAhProductos ON tCsAhorros.CodProducto = tAhProductos.idProducto INNER JOIN
                      tAhClTipoProducto ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd INNER JOIN
                      tAhClFormaManejo ON tCsAhorros.FormaManejo = tAhClFormaManejo.FormaManejo INNER JOIN
                      tAhClEstadoCuenta ON tCsAhorros.idEstadoCta = tAhClEstadoCuenta.idEstadoCta INNER JOIN
                      tAhClTipoInteres ON tCsAhorros.CodTipoInteres = tAhClTipoInteres.CodTipoInteres
WHERE        tCsAhorros.Fecha =  @Fecha   AND   tClOficinas.CodOficina =  @Oficina  AND  tCsAhorros.idEstadoCta <> 'cc' 
 and  tCsAhorros.FechaVencimiento>= @FecIni and   tCsAhorros.FechaVencimiento <= @FecFin
GO