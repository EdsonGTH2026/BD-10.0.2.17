CREATE TABLE [dbo].[tSgUsuariosAudit] (
  [item] [int] IDENTITY,
  [valores] [varchar](500) NULL,
  [revisado] [bit] NULL CONSTRAINT [DF_tSgUsuariosAudit_revisado] DEFAULT (0),
  CONSTRAINT [PK_tSgUsuariosAudit] PRIMARY KEY CLUSTERED ([item])
)
ON [PRIMARY]
GO