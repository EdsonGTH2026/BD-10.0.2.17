CREATE TABLE [dbo].[tCsBovedaSaldos] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [SaldoIniSis] [decimal](19, 4) NULL,
  [SaldoFinSis] [decimal](19, 4) NULL,
  [SaldoFinUs] [decimal](19, 4) NULL,
  CONSTRAINT [PK_tCsBovedaSaldos] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodMoneda])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsBovedaSaldos] TO [marista]
GO