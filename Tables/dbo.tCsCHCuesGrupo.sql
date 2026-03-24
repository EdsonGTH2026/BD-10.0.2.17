CREATE TABLE [dbo].[tCsCHCuesGrupo] (
  [Codigo] [int] NOT NULL,
  [CodGrupo] [int] NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [FormaGrupo] [int] NULL,
  CONSTRAINT [PK_tCsCHCuesGrupo] PRIMARY KEY CLUSTERED ([Codigo], [CodGrupo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCHCuesGrupo] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCHCuesGrupo_tCsCHCuestionarios] FOREIGN KEY ([Codigo]) REFERENCES [dbo].[tCsCHCuestionarios] ([Codigo])
GO