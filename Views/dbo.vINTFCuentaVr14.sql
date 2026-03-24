SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vINTFCuentaVr14    Script Date: 08/03/2023 09:06:02 pm ******/


CREATE view [dbo].[vINTFCuentaVr14]
AS
--00:00:16
SELECT     CodPrestamo, RTRIM(CodUsuario) AS CodUsuario, ClaveUsuario, NombreUsuario, Responsabilidad, TipoCuenta, TipoContrato, UnidadMonetaria, 
                      RTRIM(LTRIM(STR(ImporteAvaluo, 18, 0))) AS ImporteAvaluo, NumeroPagos, FrecuenciaPagos, RTRIM(LTRIM(STR(MontoPagar, 18, 0))) AS MontoPagar, 
                      Apertura, UltimoPago, Disposicion, Cancelacion, Reporte, Garantia, RTRIM(LTRIM(STR(CreditoMaximo, 18, 0))) AS CreditoMaximo, 
                      RTRIM(LTRIM(STR(SaldoActual, 18, 0))) AS SaldoActual, LimiteCredito, RTRIM(LTRIM(STR(SaldoVencido, 18, 0))) AS SaldoVencido, PagosVencidos, 
                      MOP, HistoricoPagos, Observacion, PagosReportados, MOP02, MOP03, MOP04, MOP05mas, AOClave, AONombre, AOCuenta, FprimerIncum, 
                      RTRIM(LTRIM(STR(SaldoInsoluto, 18, 0))) SaldoInsoluto, FinSegmento,
--Montoultpago as MontoUltimoPago,
convert(int,Montoultpago) as MontoUltimoPago,
' ' as FechaIngresoCarteraVencida, --opcional
0 as MontoCorrespondienteIntereses, --opcional
--' ' as FormaPagoMOP,  --opcional
MOP as FormaPagoMOP,
case when SaldoVencido=0 then 0 else DiasAtraso end as DiasVencimiento,   --opcional --> CUM 2020.11.23 se coloca que valla en cero para los liquidados o que no tienen saldo vencido
PlazoMeses,   
MontoDesembolso as MontoCreditoOriginacion,  --opcional
' ' as CorreoElectronicoConsumidor  --opcional
FROM (
	SELECT CodPrestamo, CodUsuario, ClaveUsuario, NombreUsuario, Responsabilidad, TipoCuenta, TipoContrato, UnidadMonetaria, ImporteAvaluo, 
    NumeroPagos, FrecuenciaPagos, MontoPagar, Apertura, UltimoPago, Disposicion, Cancelacion, Reporte, Garantia, CreditoMaximo, 
    SaldoActual, LimiteCredito, SaldoVencido, PagosVencidos, MOP, HistoricoPagos, Observacion, PagosReportados, MOP02, MOP03, MOP04, 
    MOP05mas, AOClave, AONombre, AOCuenta, FprimerIncum, SaldoInsoluto, FinSegmento, Montoultpago, PlazoMeses, MontoDesembolso,
	isnull(DiasAtraso,0) as DiasAtraso
	FROM FinamigoConsolidado.dbo.tCsBuroxTblReICueVr14 with(nolock)
) Datos





GO