CREATE TABLE [dbo].[tTaLog] (
  [item] [int] IDENTITY,
  [fecha] [smalldatetime] NULL,
  [hora] [datetime] NULL,
  [archivo] [varchar](200) NULL,
  CONSTRAINT [PK_TTaLog] PRIMARY KEY CLUSTERED ([item])
)
ON [PRIMARY]
GO