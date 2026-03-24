SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE View [dbo].[vCHEmpleadosCuentasVista]
As
SELECT CodOficina, NomOficina, Empleado, CodCuenta, FraccionCta, Renovado, NomCuenta, EstadoCalculado, CodUsuario
FROM (
    SELECT DISTINCT tCsEmpleados.CodOficina, tClOficinas.NomOficina, tCsEmpleados.Paterno + ' ' + tCsEmpleados.Materno + ' ' + tCsEmpleados.Nombres AS Empleado, 
                    Ahorros.CodCuenta, Ahorros.FraccionCta, Ahorros.Renovado, Ahorros.NomCuenta, Ahorros.EstadoCalculado, tCsEmpleados.CodUsuario
    FROM tCsEmpleados 
    INNER JOIN tClOficinas ON tCsEmpleados.CodOficina = tClOficinas.CodOficina 
    LEFT JOIN (
        SELECT Datos_2.CodCuenta, Datos_2.FraccionCta, Datos_2.Renovado, Datos_2.CodUsuario, Datos_2.NomCuenta, Datos_2.EstadoCalculado, Datos_2.CodProducto
        FROM (
            SELECT Datos.CodUsuario, MAX(Datos.CodCuenta) AS CodCuenta
            FROM (
                SELECT PA.CodUsuario, MIN(PA.EstadoCalculado) AS Estado
                FROM tCsPadronAhorros PA
                INNER JOIN tCsAhorros A ON PA.CodCuenta = A.CodCuenta AND PA.FraccionCta = A.FraccionCta AND PA.Renovado = A.Renovado AND PA.FechaCorte = A.Fecha
                WHERE PA.EstadoCalculado NOT IN ('CC') AND LEFT(A.CodProducto, 1) = '1'
                GROUP BY PA.CodUsuario
            ) AS Filtro 
            INNER JOIN (
                SELECT PA.CodCuenta, PA.FraccionCta, PA.Renovado, PA.CodUsuario, A.NomCuenta, PA.EstadoCalculado, A.CodProducto
                FROM tCsPadronAhorros AS PA 
                INNER JOIN tCsAhorros AS A ON PA.CodCuenta = A.CodCuenta AND PA.FraccionCta = A.FraccionCta AND PA.Renovado = A.Renovado
                WHERE PA.EstadoCalculado NOT IN ('CC') AND LEFT(A.CodProducto, 1) = '1'
            ) AS Datos ON Filtro.CodUsuario = Datos.CodUsuario AND Filtro.Estado = Datos.EstadoCalculado
            GROUP BY Datos.CodUsuario
        ) AS derivedtbl_1 
        INNER JOIN (
            SELECT Datos_1.CodCuenta, Datos_1.FraccionCta, Datos_1.Renovado, Datos_1.CodUsuario, Datos_1.NomCuenta, Datos_1.EstadoCalculado, Datos_1.CodProducto
            FROM (
                SELECT tCsPadronAhorros_2.CodUsuario, MIN(tCsPadronAhorros_2.EstadoCalculado) AS Estado
                FROM tCsPadronAhorros AS tCsPadronAhorros_2 
                INNER JOIN tCsAhorros AS tCsAhorros_2 ON tCsPadronAhorros_2.CodCuenta = tCsAhorros_2.CodCuenta AND tCsPadronAhorros_2.FraccionCta = tCsAhorros_2.FraccionCta AND tCsPadronAhorros_2.Renovado = tCsAhorros_2.Renovado AND tCsPadronAhorros_2.FechaCorte = tCsAhorros_2.Fecha
                WHERE tCsPadronAhorros_2.EstadoCalculado NOT IN ('CC') AND LEFT(tCsAhorros_2.CodProducto, 1) = '1'
                GROUP BY tCsPadronAhorros_2.CodUsuario
            ) AS Filtro_1 
            INNER JOIN (
                SELECT tCsPadronAhorros_1.CodCuenta, tCsPadronAhorros_1.FraccionCta, tCsPadronAhorros_1.Renovado, tCsPadronAhorros_1.CodUsuario, tCsAhorros_1.NomCuenta, tCsPadronAhorros_1.EstadoCalculado, tCsAhorros_1.CodProducto
                FROM tCsPadronAhorros AS tCsPadronAhorros_1 
                INNER JOIN tCsAhorros AS tCsAhorros_1 ON tCsPadronAhorros_1.CodCuenta = tCsAhorros_1.CodCuenta AND tCsPadronAhorros_1.FraccionCta = tCsAhorros_1.FraccionCta AND tCsPadronAhorros_1.Renovado = tCsAhorros_1.Renovado AND tCsPadronAhorros_1.FechaCorte = tCsAhorros_1.Fecha
                WHERE tCsPadronAhorros_1.EstadoCalculado NOT IN ('CC') AND LEFT(tCsAhorros_1.CodProducto, 1) = '1'
            ) AS Datos_1 ON Filtro_1.CodUsuario = Datos_1.CodUsuario AND Filtro_1.Estado = Datos_1.EstadoCalculado) AS Datos_2 ON derivedtbl_1.CodUsuario = Datos_2.CodUsuario AND derivedtbl_1.CodCuenta = Datos_2.CodCuenta
        ) AS Ahorros ON tCsEmpleados.CodUsuario = Ahorros.CodUsuario
        WHERE tCsEmpleados.Estado = 1
    ) AS Datos
    --ORDER BY CAST(CodOficina AS Int)

GO