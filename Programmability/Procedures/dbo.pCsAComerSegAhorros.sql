SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerSegAhorros] @fecha smalldatetime, @codoficina varchar(300)
as
SELECT a.Fecha, a.CodCuenta, a.FraccionCta, a.Renovado, a.CodOficina, tClOficinas.NomOficina, tClZona.Nombre, 
tAhProductos.Nombre AS Expr1, a.FechaApertura, a.FechaVencimiento, a.CodUsuario, tCsPadronClientes.FechaIngreso, 
tCsPadronClientes.NombreCompleto, a.SaldoCuenta, a.MontoInteres, a.IntAcumulado, a.MontoInteresCapitalizado, 
a.MontoBloqueado, a.InteresCalculado, a.Plazo, a.CodAsesor, tCsPadronClientes_1.NombreCompleto AS Asesor
FROM tCsAhorros a with(nolock) 
INNER JOIN tAhProductos with(nolock) ON a.CodProducto = tAhProductos.idProducto 
INNER JOIN tClOficinas with(nolock) ON a.CodOficina = tClOficinas.CodOficina 
INNER JOIN tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona 
INNER JOIN tCsPadronClientes with(nolock) ON a.CodUsuario = tCsPadronClientes.CodUsuario 
INNER JOIN tCsPadronClientes tCsPadronClientes_1 with(nolock) ON a.CodAsesor = tCsPadronClientes_1.CodUsuario
WHERE (a.Fecha = @fecha) 
AND ( a.CodOficina IN (select codigo from dbo.fduTablaValores(@codoficina)))
GO