SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUCADatosVariables] @Fecha smalldatetime, @Codprestamo varchar(25) , @CodUsuario varchar(25) AS
SELECT     tCsPadronClientes.NombreCompleto, tCsCartera.Estado, tCsCartera.NroDiasAtraso, tCsCartera.TipoReprog, tCsCarteraDet.UltimoMovimiento, 
                      tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas, tCsCartera.NroCuotasPorPagar, tCsCarteraDet.SReservaCapital, tCsCarteraDet.SReservaInteres, 
                      tCsCarteraDet.PReservaCapital, tCsCarteraDet.PReservaInteres, tCsCarteraDet.SaldoCapital - tCsCarteraDet.CapitalVencido AS CapitalVigente, 
                      tCsCarteraDet.CapitalVencido, tCsCarteraDet.InteresVigente, tCsCarteraDet.InteresVencido, tCsCarteraDet.InteresCtaOrden, 
                      tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, tCsCarteraDet.MoratorioCtaOrden, tCsCarteraDet.CargoMora, 
                      tCsCarteraDet.OtrosCargos, tCsCarteraDet.Impuestos
FROM         tCsCartera with(nolock) INNER JOIN
                      tCsCarteraDet with(nolock) ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN
                      tCsPadronClientes with(nolock) ON tCsCartera.CodAsesor = tCsPadronClientes.CodUsuario
WHERE     (tCsCartera.Fecha = @Fecha) AND (tCsCarteraDet.CodPrestamo = @Codprestamo) AND (tCsCarteraDet.CodUsuario = @CodUsuario)
GO