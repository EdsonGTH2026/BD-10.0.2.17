CREATE TABLE [dbo].[TmpROCAsaldoCubetas] (
  [fecha] [smalldatetime] NULL,
  [fechaPeriodo] [smalldatetime] NOT NULL,
  [Cubetas] [varchar](10) NOT NULL,
  [saldoCapitalTOTAL] [decimal](38, 4) NULL,
  [Categoria] [varchar](14) NULL
)
ON [PRIMARY]
GO