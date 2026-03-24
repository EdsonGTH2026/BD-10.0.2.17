CREATE TABLE [dbo].[SaldosBoveda] (
  [Fecha] [smalldatetime] NOT NULL,
  [DescOficina] [varchar](1033) NULL,
  [SaldoFinSisMn] [decimal](38, 4) NULL,
  [SaldoFinUsMn] [decimal](38, 4) NULL,
  [Contabilidad] [decimal](38, 4) NULL,
  [ASaldoFinSisMn] [decimal](38, 4) NULL,
  [ASaldoFinUsMn] [decimal](38, 4) NULL,
  [AContabilidad] [decimal](38, 4) NULL
)
ON [PRIMARY]
GO