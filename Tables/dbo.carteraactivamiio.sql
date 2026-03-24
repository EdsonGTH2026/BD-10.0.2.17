CREATE TABLE [dbo].[carteraactivamiio] (
  [fecha] [smalldatetime] NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [SecuenciaCliente] [int] NULL,
  [nivelcomer] [int] NULL,
  [Desembolso] [smalldatetime] NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [Monto] [decimal](18, 4) NULL,
  [TasaIntCorriente] [decimal](18, 7) NULL,
  [NroDiasAtraso] [int] NULL,
  [rangoMora] [varchar](12) NOT NULL,
  [SaldoCapital] [decimal](19, 4) NULL,
  [SaldoInteresCorriente] [decimal](19, 4) NULL,
  [saldoMoratorios] [decimal](19, 4) NULL,
  [Impuestos] [decimal](19, 4) NULL,
  [saldoTotal] [decimal](22, 4) NULL,
  [SaldoEnMora] [decimal](19, 4) NULL,
  [Cartera] [varchar](50) NULL
)
ON [PRIMARY]
GO