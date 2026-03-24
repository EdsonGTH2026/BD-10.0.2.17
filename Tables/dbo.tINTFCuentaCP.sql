CREATE TABLE [dbo].[tINTFCuentaCP] (
  [Periodo] [varchar](8) NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](400) NOT NULL,
  [Usados] [int] NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [EtiquetaSegmento] [varchar](6) NOT NULL,
  [ClaveUsuario] [varchar](14) NOT NULL,
  [NombreUsuario] [varchar](20) NOT NULL,
  [CodPrestamo] [varchar](29) NOT NULL,
  [Responsabilidad] [varchar](5) NOT NULL,
  [TipoCuenta] [varchar](5) NOT NULL,
  [TipoContrato] [varchar](6) NOT NULL,
  [UnidadMonetaria] [varchar](6) NOT NULL,
  [ImporteAvaluo] [varchar](13) NOT NULL,
  [NumeroPagos] [varchar](8) NOT NULL,
  [FrecuenciaPagos] [varchar](5) NOT NULL,
  [MontoPagar] [varchar](13) NOT NULL,
  [Apertura] [varchar](12) NOT NULL,
  [UltimoPago] [varchar](12) NOT NULL,
  [Disposicion] [varchar](12) NOT NULL,
  [Cancelacion] [varchar](12) NOT NULL,
  [Reporte] [varchar](12) NOT NULL,
  [Garantia] [varchar](44) NOT NULL,
  [CreditoMaximo] [varchar](13) NOT NULL,
  [SaldoActual] [varchar](14) NOT NULL,
  [LimiteCredito] [varchar](13) NOT NULL,
  [SaldoVencido] [varchar](13) NOT NULL,
  [PagosVencidos] [varchar](8) NOT NULL,
  [MOP] [varchar](6) NOT NULL,
  [Observacion] [varchar](6) NOT NULL,
  [AOClave] [varchar](14) NOT NULL,
  [AONombre] [varchar](20) NOT NULL,
  [AOCuenta] [varchar](29) NOT NULL,
  [FprimerIncum] [varchar](12) NULL,
  [SaldoInsoluto] [varchar](14) NULL,
  [FinSegmento] [varchar](7) NOT NULL,
  [MontoUltimoPago] [varchar](14) NULL,
  [FechaIngresoCarteraVencida] [varchar](14) NULL,
  [MontoCorrepondienteIntereses] [varchar](14) NULL,
  [FormaPagoMOP] [varchar](6) NULL,
  [DiasVencimiento] [varchar](7) NULL,
  [PlazoMeses] [varchar](10) NULL,
  [MontoCreditoOriginacion] [varchar](14) NULL,
  [CorreoElectronicoConsumidor] [varchar](104) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_Periodo_Responsabilidad_CreditoMaximo]
  ON [dbo].[tINTFCuentaCP] ([Periodo], [Responsabilidad], [CreditoMaximo])
  INCLUDE ([Fila], [Cadena], [CodUsuario], [CodPrestamo])
  ON [PRIMARY]
GO