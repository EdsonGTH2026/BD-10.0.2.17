CREATE TABLE [dbo].[tCsCHCuesRespuestas] (
  [CodUsuario] [varchar](15) NOT NULL,
  [Codigo] [int] NOT NULL,
  [NroEncuesta] [int] NOT NULL,
  [CodGrupo] [int] NOT NULL,
  [CodPregunta] [int] NOT NULL,
  [CodAlternativa] [int] NOT NULL,
  [Valor] [varchar](500) NULL,
  CONSTRAINT [PK_tCsCHCuesRespuestas] PRIMARY KEY CLUSTERED ([CodUsuario], [Codigo], [NroEncuesta], [CodGrupo], [CodPregunta], [CodAlternativa])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCHCuesRespuestas] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCHCuesRespuestas_tCsCHEncuestados] FOREIGN KEY ([CodUsuario], [Codigo], [NroEncuesta]) REFERENCES [dbo].[tCsCHEncuestados] ([CodUsuario], [Codigo], [NroEncuesta]) ON UPDATE CASCADE
GO