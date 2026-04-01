CREATE TABLE [dbo].[tSgOptions] (
  [CodSistema] [char](2) NOT NULL,
  [Opcion] [varchar](10) NOT NULL,
  [OpcionPare] [varchar](10) NULL,
  [Nombre] [varchar](60) NULL,
  [Descripcion] [varchar](200) NULL,
  [EsTerminal] [bit] NOT NULL,
  [Activo] [int] NOT NULL,
  [Icono] [image] NULL,
  [TeclaAcceso] [int] NULL,
  [AyudaCtx] [int] NULL,
  [TipoObj] [int] NULL,
  [Objeto] [varchar](50) NULL,
  [AutorizacionEspecial] [bit] NULL,
  [CodAutorizacion] [char](6) NULL,
  [ObjetoWeb] [varchar](100) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO