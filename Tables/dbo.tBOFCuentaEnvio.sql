CREATE TABLE [dbo].[tBOFCuentaEnvio] (
  [CodPrestamo] [varchar](25) NULL,
  [Responsabilidad] [varchar](5) NULL,
  [TipoCuenta] [varchar](5) NULL,
  [TipoContrato] [varchar](5) NULL,
  [UnidadMonetaria] [varchar](5) NULL,
  [NumeroPagos] [varchar](5) NULL,
  [FrecuenciaPagos] [varchar](5) NULL,
  [MontoPagar] [int] NULL,
  [Apertura] [varchar](8) NULL,
  [UltimoPago] [varchar](8) NULL,
  [Disposicion] [varchar](8) NULL,
  [Cancelacion] [varchar](8) NULL,
  [Reporte] [varchar](8) NULL,
  [CreditoMaximo] [int] NULL,
  [SaldoActual] [int] NULL,
  [LimiteCredito] [varchar](10) NULL,
  [SaldoVencido] [int] NULL,
  [PagosVencidos] [varchar](8) NULL,
  [MOP] [varchar](2) NULL,
  [Observacion] [varchar](10) NULL,
  [FinSegmento] [varchar](7) NULL
)
ON [PRIMARY]
GO