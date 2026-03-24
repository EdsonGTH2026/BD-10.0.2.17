CREATE TABLE [dbo].[TCEPadronCartera452] (
  [FechaCorte] [smalldatetime] NULL,
  [IDCliente] [varchar](30) NULL,
  [IDContrato] [varchar](30) NULL,
  [NroContrato] [varchar](30) NULL,
  [Grupo] [varchar](30) NULL,
  [Contrato] [varchar](30) NULL,
  [SaldoInicial] [money] NULL,
  [MontoPagoExigibleMes] [money] NULL,
  [MontoPagoExigible] [money] NULL,
  [MontoPagado] [money] NULL,
  [SaldoInsoluto] [money] NULL,
  [PlazoVencimiento] [int] NULL,
  [NroDiasMora] [smalldatetime] NULL,
  [AmortizacionNoCubierta] [smalldatetime] NULL,
  [ContratosGarah] [int] NULL,
  [MontoGarantia] [money] NULL
)
ON [PRIMARY]
GO