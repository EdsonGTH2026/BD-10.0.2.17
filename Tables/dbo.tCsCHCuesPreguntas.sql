CREATE TABLE [dbo].[tCsCHCuesPreguntas] (
  [Codigo] [int] NOT NULL,
  [CodGrupo] [int] NOT NULL,
  [CodPregunta] [int] NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [NroAlternativas] [int] NULL,
  [Comentario] [varchar](50) NULL CONSTRAINT [DF_tCsCHCuesPreguntas_Comentario] DEFAULT (0),
  [Comentario2] [varchar](50) NULL,
  CONSTRAINT [PK_tCsCHCuesPreguntas] PRIMARY KEY CLUSTERED ([Codigo], [CodGrupo], [CodPregunta])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCHCuesPreguntas] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCHCuesPreguntas_tCsCHCuesGrupo] FOREIGN KEY ([Codigo], [CodGrupo]) REFERENCES [dbo].[tCsCHCuesGrupo] ([Codigo], [CodGrupo])
GO