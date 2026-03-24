CREATE TABLE [dbo].[tCsPrReporte] (
  [Reporte] [varchar](10) NOT NULL,
  [Sistema] [varchar](2) NULL,
  [Nombre] [varchar](100) NULL,
  [Descripcion] [varchar](200) NULL,
  [IntervaloCartera] [bit] NULL,
  [Archivo] [varchar](100) NULL,
  [CampoRango] [varchar](500) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsPrReporte] PRIMARY KEY CLUSTERED ([Reporte])
)
ON [PRIMARY]
GO