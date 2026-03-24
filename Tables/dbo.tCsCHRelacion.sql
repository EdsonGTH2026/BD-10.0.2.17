CREATE TABLE [dbo].[tCsCHRelacion] (
  [CodFactor] [int] NOT NULL,
  [CodSubFactor] [int] NOT NULL,
  [Codigo] [int] NOT NULL,
  [CodGrupo] [int] NOT NULL,
  [CodPregunta] [int] NOT NULL,
  CONSTRAINT [PK_tCsCHRelacion] PRIMARY KEY CLUSTERED ([CodFactor], [CodSubFactor], [Codigo], [CodGrupo], [CodPregunta])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCHRelacion]
  ADD CONSTRAINT [FK_tCsCHRelacion_tCsCHSubFactores] FOREIGN KEY ([CodSubFactor], [CodFactor]) REFERENCES [dbo].[tCsCHSubFactores] ([CodSubFactor], [CodFactor]) ON DELETE CASCADE ON UPDATE CASCADE
GO