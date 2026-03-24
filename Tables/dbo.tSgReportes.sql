CREATE TABLE [dbo].[tSgReportes] (
  [CodReporte] [int] NOT NULL,
  [CodModulo] [char](3) NULL,
  [Fuentedatos] [varchar](50) NULL,
  [Nombre] [varchar](80) NULL,
  [Titulo] [varchar](200) NULL,
  [Descripcion] [varchar](500) NULL,
  [RutaUbicacion] [varchar](200) NULL,
  [RutaDesarrollo] [varchar](200) NULL,
  [FechaCreacion] [datetime] NULL CONSTRAINT [DF_tClReporte_FechaCreacion] DEFAULT (getdate()),
  [UsuarioRegistro] [varchar](50) NULL CONSTRAINT [DF_tClReporte_UsuarioRegistro] DEFAULT (suser_sname()),
  [FechaUltModificacion] [datetime] NULL CONSTRAINT [DF_tClReporte_FechaUltModificacion] DEFAULT (getdate()),
  [Activo] [bit] NULL CONSTRAINT [DF_tClReporte_Activo] DEFAULT (1),
  [PublicadoWeb] [bit] NULL CONSTRAINT [DF_tClReporte_PublicadoWeb] DEFAULT (0),
  [PersHeader] [varchar](8000) NULL,
  [PersAutoFiltro] [char](1) NULL CONSTRAINT [DF_tSgReportes_PersAutoFiltro] DEFAULT (0),
  [PersHeadFilter] [varchar](8000) NULL,
  [PersColTipo] [varchar](100) NULL,
  [PersGridAncho] [int] NULL,
  [PersGridAlto] [int] NULL,
  [PersColAncho] [varchar](100) NULL,
  [PersColAling] [varchar](100) NULL,
  [PersColOrden] [varchar](100) NULL,
  CONSTRAINT [PK_tClReporte] PRIMARY KEY CLUSTERED ([CodReporte])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'código del reporte', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'CodReporte'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'código del módulo', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'CodModulo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Procedimiento almacenado que sierven de fuentes de datos (solo procedimientos con prefijo ''pRpt...'')', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'Fuentedatos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'nombre corto del reporte', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'Nombre'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'titulo del reporte', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'Titulo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'descripción del reporte, especifica la finalidad', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'Descripcion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Ruta local de ubicación para que se ejecuten los reportes', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'RutaUbicacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Ruta de desarrollo donde se encuentran los reportes y que sirve de fuente cuando el reporte no este en la ruta local', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'RutaDesarrollo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de creación del reporte', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'FechaCreacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'usuario sql que creo el reporte', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'UsuarioRegistro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha ultima que se modifico el reporte', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'FechaUltModificacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1=Activo, 0=Inactivo', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'Activo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0 = no publicado, 1=publicado', 'SCHEMA', N'dbo', 'TABLE', N'tSgReportes', 'COLUMN', N'PublicadoWeb'
GO