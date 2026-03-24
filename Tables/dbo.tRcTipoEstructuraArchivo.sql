CREATE TABLE [dbo].[tRcTipoEstructuraArchivo] (
  [TipoArchivoTexto] [varchar](3) NOT NULL,
  [EstructuraArchivo] [varchar](2) NOT NULL,
  [Tabla] [varchar](50) NULL,
  [TablaRecorrido] [varchar](50) NULL,
  [OrdenadoPor] [varchar](100) NULL,
  [Periodo] [varchar](6) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tOpnTipoEstructuraArchivo] PRIMARY KEY CLUSTERED ([TipoArchivoTexto], [EstructuraArchivo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tRcTipoEstructuraArchivo] WITH NOCHECK
  ADD CONSTRAINT [FK_tRcTipoEstructuraArchivo_tRcEstructuraArchivo] FOREIGN KEY ([EstructuraArchivo]) REFERENCES [dbo].[tRcEstructuraArchivo] ([EstructuraArchivo])
GO

ALTER TABLE [dbo].[tRcTipoEstructuraArchivo] WITH NOCHECK
  ADD CONSTRAINT [FK_tRcTipoEstructuraArchivo_tRcTipoArchivoTexto] FOREIGN KEY ([TipoArchivoTexto]) REFERENCES [dbo].[tRcTipoArchivoTexto] ([TipoArchivoTexto])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del tipo de archivo', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoEstructuraArchivo', 'COLUMN', N'TipoArchivoTexto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la estructura del archivo', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoEstructuraArchivo', 'COLUMN', N'EstructuraArchivo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la tabla', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoEstructuraArchivo', 'COLUMN', N'Tabla'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la vista', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoEstructuraArchivo', 'COLUMN', N'TablaRecorrido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Campo por el cual se va ordenar el registro', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoEstructuraArchivo', 'COLUMN', N'OrdenadoPor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Periodo', 'SCHEMA', N'dbo', 'TABLE', N'tRcTipoEstructuraArchivo', 'COLUMN', N'Periodo'
GO