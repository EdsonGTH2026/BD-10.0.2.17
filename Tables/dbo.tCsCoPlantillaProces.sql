CREATE TABLE [dbo].[tCsCoPlantillaProces] (
  [IDSession] [varchar](20) NOT NULL,
  [Reporte] [char](2) NOT NULL,
  [Codigo] [varchar](10) NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [Nivel] [int] NULL,
  [NivelReporte] [int] NULL,
  [OrdenNivel] [int] NULL,
  [Operacion] [varchar](500) NULL,
  [CuentaCampo] [varchar](200) NULL,
  [valor] [decimal](18, 4) NULL,
  [oculto] [char](1) NULL,
  [Grupo] [varchar](10) NULL,
  [Fuente] [varchar](10) NULL,
  CONSTRAINT [PK_tCsCoPlantilla] PRIMARY KEY CLUSTERED ([IDSession], [Reporte], [Codigo])
)
ON [PRIMARY]
GO