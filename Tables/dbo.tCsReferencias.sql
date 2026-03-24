CREATE TABLE [dbo].[tCsReferencias] (
  [CodUsuario] [char](15) NOT NULL,
  [CodTipoReferencia] [char](3) NOT NULL,
  [IdReferencia] [int] NOT NULL,
  [CodRefRelacion] [char](3) NULL,
  [Consolidacion] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Nombre] [varchar](80) NULL,
  [Direccion] [varchar](100) NULL,
  [Telefono] [varchar](20) NULL,
  [Observaciones] [varchar](200) NULL,
  [Campo1] [varchar](50) NULL,
  CONSTRAINT [PK_tCsReferencias] PRIMARY KEY CLUSTERED ([CodUsuario], [CodTipoReferencia], [IdReferencia], [CodOficina])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la institucion juridica.', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de tipo de referencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'CodTipoReferencia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Secuencial de la referencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'IdReferencia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la relación', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'CodRefRelacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la referencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'Nombre'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Dirección de la referencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'Direccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la referencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'Telefono'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Observaciones sobre la referencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'Observaciones'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Campo1 para información adicional', 'SCHEMA', N'dbo', 'TABLE', N'tCsReferencias', 'COLUMN', N'Campo1'
GO