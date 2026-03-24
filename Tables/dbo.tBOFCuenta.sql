CREATE TABLE [dbo].[tBOFCuenta] (
  [CodPrestamo] [varchar](29) NULL,
  [CodUsuario] [varchar](15) NULL,
  [Responsabilidad] [varchar](5) NULL,
  [TipoCuenta] [varchar](5) NULL,
  [TipoContrato] [varchar](6) NULL,
  [UnidadMonetaria] [varchar](6) NULL,
  [NumeroPagos] [varchar](8) NULL,
  [FrecuenciaPagos] [varchar](5) NULL,
  [MontoPagar] [money] NULL,
  [Apertura] [varchar](12) NULL,
  [UltimoPago] [varchar](12) NULL,
  [Disposicion] [varchar](12) NULL,
  [Cancelacion] [varchar](12) NULL,
  [Reporte] [varchar](12) NULL,
  [CreditoMaximo] [money] NULL,
  [SaldoActual] [money] NULL,
  [LimiteCredito] [varchar](13) NULL,
  [SaldoVencido] [money] NULL,
  [PagosVencidos] [varchar](8) NULL,
  [MOP] [varchar](6) NULL,
  [Observacion] [varchar](6) NULL,
  [FinSegmento] [varchar](7) NULL,
  [MontoUltimoPago] [money] NULL
)
ON [PRIMARY]
GO