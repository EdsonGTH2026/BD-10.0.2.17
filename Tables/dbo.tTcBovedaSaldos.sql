CREATE TABLE [dbo].[tTcBovedaSaldos] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechaPro] [smalldatetime] NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [SaldoIniSis] [money] NULL,
  [SaldoFinSis] [money] NULL,
  [SaldoFinUs] [money] NULL
)
ON [PRIMARY]
GO