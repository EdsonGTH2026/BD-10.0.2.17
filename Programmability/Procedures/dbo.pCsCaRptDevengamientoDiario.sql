SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptDevengamientoDiario] @FecIni smalldatetime, @FecFin smalldatetime AS
SELECT     tCsCartera.Fecha, SUM(tCsCarteraDet.MontoDesembolso) AS MontoDesembolso, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, SUM(tCsCarteraDet.SaldoInteres) 
                      AS SaldoInteres, SUM(tCsCarteraDet.SaldoMoratorio) AS SaldoMoratorio, tCsCartera.Estado, SUM(tCsCarteraDet.InteresVigente) AS InteresVigente, 
                      SUM(tCsCarteraDet.InteresVencido) AS InteresVencido, SUM(tCsCarteraDet.InteresCtaOrden) AS InteresCtaOrden, SUM(tCsCarteraDet.InteresDevengado) 
                      AS InteresDevengado, SUM(tCsCarteraDet.MoratorioVigente) AS MoratorioVigente, SUM(tCsCarteraDet.MoratorioVencido) AS MoratorioVencido, 
                      SUM(tCsCarteraDet.MoratorioCtaOrden) AS MoratorioCtaOrden, SUM(tCsCarteraDet.MoratorioDevengado) AS MoratorioDevengado, tCsCartera.Cartera
FROM         tCsCarteraDet INNER JOIN
                      tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
WHERE     ((tCsCartera.Fecha >= @FecIni)  and (tCsCartera.Fecha <= @FecFin ) ) AND (tCsCartera.Cartera = 'ACTIVA') and tCsCartera.CodOficina in (Select codoficina from tcloficinas)
GROUP BY tCsCartera.Fecha, tCsCartera.Estado, tCsCartera.Cartera
GO