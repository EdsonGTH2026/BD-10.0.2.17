CREATE TABLE [dbo].[tCsCHSubFactores] (
  [CodFactor] [int] NOT NULL,
  [CodSubFactor] [int] NOT NULL,
  [Codigo] [varchar](10) NULL,
  [Descripcion] [varchar](100) NULL,
  CONSTRAINT [PK_tCsCHSubFactores] PRIMARY KEY CLUSTERED ([CodSubFactor], [CodFactor])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCHSubFactores] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCHSubFactores_tCsCHFactores] FOREIGN KEY ([CodFactor]) REFERENCES [dbo].[tCsCHFactores] ([CodFactor]) ON DELETE CASCADE ON UPDATE CASCADE
GO