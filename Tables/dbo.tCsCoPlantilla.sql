CREATE TABLE [dbo].[tCsCoPlantilla] (
  [Reporte] [char](2) NOT NULL,
  [Codigo] [varchar](10) NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [Nivel] [int] NULL,
  [NivelReporte] [int] NULL,
  [OrdenNivel] [int] NULL,
  [TipoValor] [varchar](2) NULL,
  [Basedatos] [varchar](2) NULL,
  [Operacion] [varchar](500) NULL,
  [CuentaCampo] [varchar](200) NULL,
  [TipoCampo] [varchar](20) NULL,
  [Observacion] [text] NULL,
  [valor] [decimal](18, 2) NULL,
  [Oculto] [char](1) NULL CONSTRAINT [DF_tCsCoCatalogoMinimo_Oculto] DEFAULT (0),
  [Grupo] [varchar](10) NULL CONSTRAINT [DF_tCsCoPlantilla_Grupo] DEFAULT (''),
  [Fuente] [varchar](10) NULL,
  CONSTRAINT [PK_tCsCoCatalogoMinimo] PRIMARY KEY CLUSTERED ([Reporte], [Codigo])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO