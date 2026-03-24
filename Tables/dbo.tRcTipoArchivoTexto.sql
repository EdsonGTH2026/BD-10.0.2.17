CREATE TABLE [dbo].[tRcTipoArchivoTexto] (
  [TipoArchivoTexto] [varchar](3) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  CONSTRAINT [PK_tOpnTipoArchivoTexto] PRIMARY KEY CLUSTERED ([TipoArchivoTexto])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de archvo de texto', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoArchivoTexto', 'COLUMN', N'TipoArchivoTexto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del Archivo', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoArchivoTexto', 'COLUMN', N'Nombre'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripción del archivo', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoArchivoTexto', 'COLUMN', N'Descripcion'
GO