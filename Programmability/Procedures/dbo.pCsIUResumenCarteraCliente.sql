SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUResumenCarteraCliente] @CodUsuario varchar(25) AS
SELECT     tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.Desembolso, tCsPadronCarteraDet.Cancelacion, tCsPadronCarteraDet.EstadoCalculado, 
                     NroDiasAtraso = 'Atra: ' + cast(tCsCartera.NroDiasAtraso as Varchar(10)) + ', Acum: ' + cast( isnull(tCsCartera.NroDiasAcumulado, 0) as Varchar(10)) , tCsCarteraDet.MontoDesembolso, tCsPadronCarteraDet.SaldoCalculado AS SaldoCapital, 
                      CASE tCsPadronCarteraDet.EstadoCalculado WHEN 'CANCELADO' THEN 0 ELSE tCsCarteraDet.SaldoCapital + tCsCarteraDet.OtrosCargos + tCsCarteraDet.Impuestos
                       + tCsCarteraDet.CargoMora + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioVigente
                       + tCsCarteraDet.MoratorioVencido + tCsCarteraDet.MoratorioCtaOrden END AS DeudaTotal
FROM         tCsCarteraDet with(nolock) INNER JOIN
                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo INNER JOIN
                      tCsPadronCarteraDet with(nolock) ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND 
                      tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario AND tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte
WHERE     (tCsPadronCarteraDet.CodUsuario = @CodUsuario)
order by tCsPadronCarteraDet.Desembolso desc
GO