CREATE TABLE [dbo].[tCsRptBonoSupervidorComunal] (
  [codoficina] [varchar](4) NULL,
  [nomoficina] [varchar](100) NULL,
  [nroactual] [int] NULL,
  [nroanterior] [int] NULL,
  [nrocrecimiento] [int] NULL,
  [saldoactual] [decimal](16, 2) NULL,
  [saldoanterior] [decimal](16, 2) NULL,
  [saldom0actual] [decimal](16, 2) NULL,
  [saldom0anterior] [decimal](16, 2) NULL,
  [saldopico] [decimal](16, 2) NULL,
  [saldocrecimiento] [decimal](17, 2) NULL,
  [saldoPorcrecimiento] [decimal](8, 2) NULL,
  [moraactual] [decimal](12, 4) NULL,
  [moraanterior] [decimal](12, 4) NULL,
  [BonoCreClientes] [numeric](16, 2) NOT NULL,
  [BonoCreCartera] [numeric](16, 2) NULL,
  [FactorDeduMora] [numeric](16, 2) NULL
)
ON [PRIMARY]
GO