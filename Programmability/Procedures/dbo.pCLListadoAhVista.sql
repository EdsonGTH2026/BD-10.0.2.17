SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCLListadoAhVista] @CodUsuario varchar(15) AS
SELECT pr.Abreviatura Tipo, pa.CodCuenta Número, ca.SaldoCuenta Saldo,ca.Intacumulado as IntDev FROM tCsPadronAhorros 
    pa INNER JOIN tCsAhorros ca ON pa.CodCuenta = ca.CodCuenta AND pa.FraccionCta = 
    ca.FraccionCta AND pa.Renovado = ca.Renovado AND pa.FechaCorte = ca.Fecha LEFT OUTER JOIN 
    tAhProductos pr ON pa.CodProducto = pr.idProducto 
    WHERE pa.estadocalculado<>'CC' AND (pr.idTipoProd = 1) AND (pa.CodUsuario = @CodUsuario)
GO