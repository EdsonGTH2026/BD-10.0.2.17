CREATE TABLE [dbo].[tAlertasPersonasBloqueadas] (
  [Id] [int] IDENTITY,
  [IdPersonaBloqueada] [int] NOT NULL,
  [FechaSistema] [datetime] NOT NULL,
  [RptaRegla] [int] NOT NULL,
  CONSTRAINT [PK_tAlertasPersonasBloqueadas] PRIMARY KEY CLUSTERED ([Id])
)
ON [PRIMARY]
GO