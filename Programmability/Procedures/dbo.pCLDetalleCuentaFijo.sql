SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCLDetalleCuentaFijo] @Codcuenta varchar(30) AS
    SELECT pr.Abreviatura Producto, pa.FecApertura 'Fecha Apertura' ,csa.SaldoCuenta 'Saldo Apertura', csa.FechaVencimiento 'Fecha Vencimiento', ec.Descripcion Estado, 
    OFi.NomOficina Sucursal, fm.Nombre 'Forma manejo', csa.TasaInteres 'Interes Anual', 
    csa.FechaUltMov 'Ultimo movimiento',  csa.MontoBloqueado 'Monto bloqueado', 
    csa.Intacumulado 'Interes Devengado', csa.NomCuenta 'Nombre Cuenta', oft.NomOficina AS 
    'Suc. ultima transaccion' FROM tCsPadronAhorros pa INNER JOIN tCsAhorros csa 
    ON pa.CodCuenta = csa.CodCuenta AND pa.FraccionCta = csa.FraccionCta AND pa.Renovado = csa.Renovado AND 
    pa.FechaCorte = csa.Fecha INNER JOIN tClOficinas OFi ON pa.CodOficina = OFi.CodOficina LEFT OUTER JOIN 
    tClOficinas oft ON csa.CodOficinaUltTransaccion = oft.CodOficina LEFT OUTER JOIN 
    tAhClFormaManejo fm ON csa.FormaManejo = fm.FormaManejo LEFT OUTER JOIN tAhClEstadoCuenta ec ON 
    pa.EstadoCalculado = ec.idEstadoCta LEFT OUTER JOIN tAhProductos pr ON csa.CodProducto = pr.idProducto 
WHERE (pa.CodCuenta = @Codcuenta)
GO