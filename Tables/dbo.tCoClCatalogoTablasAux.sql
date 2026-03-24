CREATE TABLE [dbo].[tCoClCatalogoTablasAux] (
  [Codtabla] [int] NOT NULL,
  [NombreTabla] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [EsBloqueada] [bit] NULL,
  [Subtipos] [bit] NULL,
  [CampoSubTipo] [varchar](50) NULL,
  [TablaSubTipos] [varchar](50) NULL
)
ON [PRIMARY]
GO