CREATE TABLE [dbo].[tSgOptions] (
  [CodSistema] [char](2) NOT NULL,
  [Opcion] [varchar](10) NOT NULL,
  [OpcionPare] [varchar](10) NULL,
  [Nombre] [varchar](60) NULL,
  [Descripcion] [varchar](200) NULL,
  [EsTerminal] [bit] NOT NULL CONSTRAINT [DF_tSgMenus_EsTerminal] DEFAULT (1),
  [Activo] [int] NOT NULL CONSTRAINT [DF_tSgMenus_Activo] DEFAULT (1),
  [Icono] [image] NULL,
  [TeclaAcceso] [int] NULL,
  [AyudaCtx] [int] NULL,
  [TipoObj] [int] NULL,
  [Objeto] [varchar](50) NULL,
  [AutorizacionEspecial] [bit] NULL CONSTRAINT [DF_tSgMenus_AutorizacionEspecial] DEFAULT (0),
  [CodAutorizacion] [char](6) NULL,
  [ObjetoWeb] [varchar](100) NULL,
  CONSTRAINT [PK_tSgMenus] PRIMARY KEY CLUSTERED ([CodSistema], [Opcion])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tSgOptions] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgMenus_tClTipoObjeto] FOREIGN KEY ([TipoObj]) REFERENCES [dbo].[tSgClTipoObjeto] ([TipoObj])
GO