CREATE TABLE [dbo].[tCsAnalisisProvision] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [MovCapital] [smallmoney] NULL,
  [MovInteres] [smallmoney] NULL,
  [Validacion] [varchar](50) NULL,
  CONSTRAINT [PK_tCsAnalisisProvision] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsAnalisisProvision]
  ON [dbo].[tCsAnalisisProvision] ([Validacion])
  ON [PRIMARY]
GO