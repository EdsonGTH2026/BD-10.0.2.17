CREATE TABLE [dbo].[ReporteComportamiento] (
  [FechaInicioReporte] [smalldatetime] NULL,
  [FechaFinReporte] [smalldatetime] NULL,
  [ClaveEmisor] [varchar](50) NOT NULL,
  [LineaNegocio] [int] NOT NULL,
  [TipoTransaccion] [int] NULL,
  [TipoEnvio] [varchar](1) NULL,
  [IdLineaCredito] [smallint] NULL,
  [CveOriginador] [varchar](50) NOT NULL,
  [IdMicroCreditoIF] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](25) NOT NULL,
  [SaldoInsolutoInicio] [decimal](23, 4) NOT NULL,
  [TotalCargos] [decimal](38, 4) NOT NULL,
  [TotalAbonos] [decimal](38, 4) NOT NULL,
  [TotalDisposiciones] [int] NOT NULL,
  [NumeroPagosProgramados] [int] NOT NULL,
  [SaldoInsolutoFinal] [decimal](23, 4) NULL,
  [NumeroDiasAtrasadosPago] [int] NULL,
  [NumeroUltimoPago] [smallint] NULL,
  [FechaUltimoPago] [datetime] NULL
)
ON [PRIMARY]
GO