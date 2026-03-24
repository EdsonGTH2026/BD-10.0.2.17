CREATE TABLE [dbo].[tCsBuroCarga] (
  [Carga] [int] IDENTITY,
  [Fecha] [smalldatetime] NULL,
  [Registros] [decimal] NULL,
  [HoraCarga] [datetime] NOT NULL,
  CONSTRAINT [PK_tCsBuroCarga] PRIMARY KEY CLUSTERED ([Carga])
)
ON [PRIMARY]
GO