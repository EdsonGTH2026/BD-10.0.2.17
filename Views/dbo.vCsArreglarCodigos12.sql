SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE View [dbo].[vCsArreglarCodigos12]
As
SELECT     vCsSAT.CodUsuario AS Antiguo, tCsPadronClientes.CodUsuario AS Actual
FROM         vCsSAT INNER JOIN
                      tCsAhorros ON vCsSAT.Corte = tCsAhorros.Fecha AND vCsSAT.Cuenta = tCsAhorros.CodCuenta INNER JOIN
                      tCsPadronClientes ON tCsAhorros.NomCuenta = tCsPadronClientes.NombreCompleto AND tCsAhorros.CodOficina = tCsPadronClientes.CodOficina
WHERE     (vCsSAT.CodTPersona = '') OR
                      (vCsSAT.IDE IS NULL) OR
                      (vCsSAT.IVA IS NULL) OR
                      (vCsSAT.RFC IS NULL)
GO