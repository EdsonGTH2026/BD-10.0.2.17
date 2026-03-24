CREATE TABLE [dbo].[tUsClOtrosDatos] (
  [IdUsOtroDato] [int] NOT NULL,
  [CodSistema] [char](2) NULL,
  [CodProducto] [varchar](4) NULL,
  [EsPerNatural] [bit] NOT NULL,
  [CodTipoUs] [varchar](5) NULL,
  [DatoDesc] [varchar](30) NULL,
  [Mascara] [varchar](20) NULL,
  [Lista] [varchar](250) NULL,
  [MultipleElec] [bit] NULL,
  [SoloParentesis] [bit] NULL,
  [Requerido] [bit] NOT NULL,
  [Activo] [bit] NOT NULL,
  [Grupo] [tinyint] NULL,
  [Orden] [tinyint] NULL
)
ON [PRIMARY]
GO