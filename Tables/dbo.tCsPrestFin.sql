CREATE TABLE [dbo].[tCsPrestFin] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodPrestFin] [varchar](3) NOT NULL,
  [CodTipoInstFin] [varchar](3) NOT NULL,
  [Categoria] [char](1) NOT NULL,
  [Estado] [char](1) NOT NULL,
  CONSTRAINT [PK_tCsPrestFin] PRIMARY KEY CLUSTERED ([CodOficina], [CodPrestFin])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Almacena los datos de Financiamiento - Inversión para los reportes regulatorios de FIMEDER.', 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del libro Auxiliar relacionado', 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestFin', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del Financiamiento - Inversión', 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestFin', 'COLUMN', N'CodPrestFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del tipo de institución financiera (tCoClTipoInstFin)', 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestFin', 'COLUMN', N'CodTipoInstFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1: Inversion; 2: Financiamiento', 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestFin', 'COLUMN', N'Categoria'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0: Inactivo; 1: Activo', 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestFin', 'COLUMN', N'Estado'
GO