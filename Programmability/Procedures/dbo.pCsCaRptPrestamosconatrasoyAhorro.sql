SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[pCsCaRptPrestamosconatrasoyAhorro] @CodOficina varchar(100) , @Fecha smalldatetime   AS

SELECT     tClOficinas.NomOficina, tCsCartera.Cartera, tCsCartera.Fecha, tCsCartera.CodPrestamo, tCsCartera.NroDiasAtraso, ISNULL(tCsCarteraGrupos.NombreGrupo, 
                      tCsPadronClientes.NombreCompleto) AS Grupo, tCsPadronClientes.NombreCompleto AS Clientes, tCsCarteraDet.SaldoCapital, tCsCarteraDet.InteresVigente, 
                      tCsCarteraDet.InteresVencido, tCsCarteraDet.InteresCtaOrden, tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, tCsCarteraDet.MoratorioCtaOrden, 
                      tCsCarteraDet.OtrosCargos, tCsCarteraDet.Impuestos, tCsCarteraDet.CargoMora, tCsClientesAhorrosFecha.CodCuenta, tCsClientesAhorrosFecha.FraccionCta, 
                      tCsClientesAhorrosFecha.Renovado, tCsClientesAhorrosFecha.Capital, tCsClientesAhorrosFecha.Interes
FROM         tCsCartera INNER JOIN
                      tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
                      tCsClientesAhorrosFecha ON tCsCarteraDet.Fecha = tCsClientesAhorrosFecha.Fecha AND 
                      tCsCarteraDet.CodUsuario = tCsClientesAhorrosFecha.CodUsCuenta INNER JOIN
                      tCsPadronClientes ON tCsCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
                      tClOficinas ON tCsCarteraDet.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
                      tCsCarteraGrupos ON tCsCartera.CodOficina = tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo
WHERE         (tCsCartera.CodOficina = @Codoficina) and  (tCsCartera.Fecha = @Fecha) AND (tCsCartera.NroDiasAtraso >= 1) AND (tCsCartera.NroDiasAtraso <= 9999999)
ORDER BY  tCsCartera.CodOficina, tCsCartera.Cartera, tCsCartera.CodPrestamo
GO