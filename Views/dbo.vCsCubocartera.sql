SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create view [dbo].[vCsCubocartera]
with encryption
as 

SELECT     1 AS Cantidad, YEAR(Fecha) * 10000 + MONTH(Fecha) * 100 + DAY(Fecha) AS Fecha, CodPrestamo, CodSolicitud, CodOficina, CodProducto, CodAsesor, 
                      CodUsuario, CodGrupo, CodFondo, CodTipoCredito, CodDestino, NivelAprobacion, Estado, TipoReprog, NroDiasCredito, ModalidadPlazo, NroCuotas, 
                      NroCuotasPagadas, NroCuotasPorPagar, NroDiasPagocuota1, NrodiasEntreCuotas, FechaSolicitud, FechaAprobacion, FechaDesembolso, 
                      FechaVencimiento, MontoDesembolso, SaldoCapital, CodMoneda, TipoCambio, NumReprog, FechaReprog, PrestamoReprog, 
                      CapitalMonetizado AS SaldoCapitalMonetizado, NroDiasAtraso, CapitalVigente AS SaldoCapitalAtrasado, CapitalVencido AS SaldoCapitalVencido, 
                      SaldoInteresCorriente AS SaldoINTE, SaldoINPE, SaldoEnMora, SaldoOtrosCargos, CodRuta, Calificacion, ProvisionCapital AS PrevisionCapital, 
                      ProvisionInteres AS PrevisionInteres, GarantiaLiquidaMonetizada, GarantiaPreferidaMonetizada, GarantiaMuyRapidaRealizacion, TotalGarantia, 
                      FechaUltimoMovimiento, TasaIntCorriente, CargoMora AS SalCargoMora, TasaINVE, TasaINPE, CodAnterior, TipoCalificacion, SaldoINTEVig AS PDInte, 
                      SaldoINPEVig AS PDInpe, SaldoINTESus AS PSInte, SaldoINPESus AS PSInpe, ComisionDesembolso, Fecha AS FechaProceso, '' AS CodAsesor2, 
                      0 AS SaldoMontoConcecional, 0 AS SaldoInteresDiferido, 0 AS IntCobrar
FROM         tCsCartera
GO