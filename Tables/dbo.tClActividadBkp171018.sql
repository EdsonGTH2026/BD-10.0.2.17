CREATE TABLE [dbo].[tClActividadBkp171018] (
  [CodActividad] [varchar](10) NOT NULL,
  [Nombre] [varchar](100) NULL,
  [Descripcion] [varchar](255) NULL,
  [CodAlterno] [varchar](10) NOT NULL,
  [EsTerminal] [bit] NOT NULL,
  [Riesgo] [varchar](10) NULL,
  [Activo] [int] NULL,
  [Sistema] [tinyint] NULL
)
ON [PRIMARY]
GO