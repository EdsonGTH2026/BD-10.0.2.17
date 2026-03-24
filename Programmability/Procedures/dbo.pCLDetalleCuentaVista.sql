SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCLDetalleCuentaVista] @codcuenta varchar(30) AS
 SELECT pr.Abreviatura Producto, pa.FecApertura 'Fecha apertura',csa.FechaVencimiento 'Fecha vencimiento', ec.Descripcion Estado, 
    OFi.NomOficina Sucursal, fm.Nombre 'Forma manejo', csa.TasaInteres 'Tasa Anual', 
    csa.FechaUltMov 'Ultimo movimiento', csa.SaldoCuenta 'Saldo cuenta', csa.MontoBloqueado 'Monto bloqueado', 
    csa.InteresCalculado 'Interes Calculado', csa.NomCuenta 'Nombre cuenta', oft.NomOficina AS 
    'Suc. ultima transaccion' FROM tCsPadronAhorros pa INNER JOIN tCsAhorros csa 
    ON pa.CodCuenta = csa.CodCuenta AND pa.FraccionCta = csa.FraccionCta AND pa.Renovado = csa.Renovado AND 
    pa.FechaCorte = csa.Fecha INNER JOIN tClOficinas OFi ON pa.CodOficina = OFi.CodOficina LEFT OUTER JOIN 
    tClOficinas oft ON csa.CodOficinaUltTransaccion = oft.CodOficina LEFT OUTER JOIN 
    tAhClFormaManejo fm ON csa.FormaManejo = fm.FormaManejo LEFT OUTER JOIN tAhClEstadoCuenta ec ON 
    pa.EstadoCalculado = ec.idEstadoCta LEFT OUTER JOIN tAhProductos pr ON csa.CodProducto = pr.idProducto 
    WHERE (pa.CodCuenta = @codcuenta)
GO