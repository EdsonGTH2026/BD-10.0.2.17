CREATE TABLE [dbo].[tTcCajasSaldos] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechaPro] [smalldatetime] NOT NULL,
  [NumCaja] [tinyint] NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [SaldoFinSis] [money] NULL,
  [SaldoFinUs] [money] NULL
)
ON [PRIMARY]
GO