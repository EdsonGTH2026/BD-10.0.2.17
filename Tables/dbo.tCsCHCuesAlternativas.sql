CREATE TABLE [dbo].[tCsCHCuesAlternativas] (
  [Codigo] [int] NOT NULL,
  [CodGrupo] [int] NOT NULL,
  [CodPregunta] [int] NOT NULL,
  [CodAlternativa] [int] NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [Valor] [varchar](50) NULL,
  CONSTRAINT [PK_tCsCHCuesAlternativas] PRIMARY KEY CLUSTERED ([Codigo], [CodGrupo], [CodPregunta], [CodAlternativa])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCHCuesAlternativas] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCHCuesAlternativas_tCsCHCuesPreguntas] FOREIGN KEY ([Codigo], [CodGrupo], [CodPregunta]) REFERENCES [dbo].[tCsCHCuesPreguntas] ([Codigo], [CodGrupo], [CodPregunta]) ON DELETE CASCADE ON UPDATE CASCADE
GO