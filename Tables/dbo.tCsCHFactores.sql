CREATE TABLE [dbo].[tCsCHFactores] (
  [CodFactor] [int] NOT NULL,
  [Codigo] [varchar](10) NULL,
  [Descripcion] [varchar](100) NULL,
  CONSTRAINT [PK_tCsCHFactores] PRIMARY KEY CLUSTERED ([CodFactor])
)
ON [PRIMARY]
GO