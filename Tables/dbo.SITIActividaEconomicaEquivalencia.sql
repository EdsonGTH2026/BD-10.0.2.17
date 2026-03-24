CREATE TABLE [dbo].[SITIActividaEconomicaEquivalencia] (
  [CodUsuario] [varchar](15) NOT NULL,
  [LabCodActividad] [varchar](6) NULL,
  [Nombre] [varchar](80) NULL,
  [Actividad] [varchar](50) NULL,
  [SITI] [char](10) NULL,
  CONSTRAINT [PK_SITIActividaEconimicaEquivalencia] PRIMARY KEY CLUSTERED ([CodUsuario])
)
ON [PRIMARY]
GO