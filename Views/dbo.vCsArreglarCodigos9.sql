SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsArreglarCodigos9]
AS
SELECT     *
FROM         (SELECT     *, CASE WHEN RIGHT(ltrim(rtrim(Codusuario)), 7) = RIGHT(ltrim(rtrim(cliente)), 7) THEN 1 ELSE 0 END AS Compara
                       FROM          (SELECT DISTINCT 
                                                                      tCsPadronCarteraDet.CodUsuario, tCsPadronCarteraDet.CodPrestamo, tCsUnisapCA.CodUsuario AS UNISAP, 
                                                                      tCsPadronClientes_1.CodUsuario AS CLIENTE
                                               FROM          tCsPadronClientes tCsPadronClientes_1 RIGHT OUTER JOIN
                                                                      tCsUnisapCA ON tCsPadronClientes_1.NombreCompleto = tCsUnisapCA.NombreCompleto RIGHT OUTER JOIN
                                                                      tCsPadronCarteraDet ON tCsUnisapCA.CodPrestamo = tCsPadronCarteraDet.CodPrestamo LEFT OUTER JOIN
                                                                      tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario
                                               WHERE      (tCsPadronClientes.CodUsuario IS NULL)) Datos) datos
WHERE     (Compara = 1)



GO