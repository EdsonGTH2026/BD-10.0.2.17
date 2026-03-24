CREATE TABLE [dbo].[SITIActividaEconomica] (
  [CodActividad] [varchar](7) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](255) NULL,
  [CodAlterno] [varchar](10) NULL,
  [EsTerminal] [bit] NULL,
  CONSTRAINT [PK_SITIActividaEconomica] PRIMARY KEY CLUSTERED ([CodActividad])
)
ON [PRIMARY]
GO