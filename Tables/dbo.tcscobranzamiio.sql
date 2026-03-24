CREATE TABLE [dbo].[tcscobranzamiio] (
  [fecha] [smalldatetime] NULL,
  [codprestamo] [varchar](25) NULL,
  [nrodiasatraso] [int] NULL,
  [capital] [money] NULL,
  [interes] [money] NULL,
  [moratorios2] [money] NULL,
  [IVAinteres] [numeric](22, 6) NULL,
  [pagoTotal] [numeric](23, 6) NULL
)
ON [PRIMARY]
GO