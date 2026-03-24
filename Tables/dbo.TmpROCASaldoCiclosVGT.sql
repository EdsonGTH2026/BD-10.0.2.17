CREATE TABLE [dbo].[TmpROCASaldoCiclosVGT] (
  [fechaCorte] [smalldatetime] NULL,
  [fechaperiodo] [smalldatetime] NOT NULL,
  [saldoCapital] [money] NULL,
  [nroCreditos] [int] NULL,
  [rangoCiclo] [varchar](12) NOT NULL
)
ON [PRIMARY]
GO