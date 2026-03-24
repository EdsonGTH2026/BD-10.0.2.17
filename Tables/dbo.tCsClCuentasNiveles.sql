CREATE TABLE [dbo].[tCsClCuentasNiveles] (
  [NroNivel] [smallint] NOT NULL,
  [Longitud] [smallint] NOT NULL,
  [DescNivel] [varchar](30) NOT NULL,
  [LongitudTotal] [smallint] NOT NULL,
  [TipoNivel] [char](1) NULL
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de nivel', 'SCHEMA', N'dbo', 'TABLE', N'tCsClCuentasNiveles', 'COLUMN', N'NroNivel'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Longitud del nivel', 'SCHEMA', N'dbo', 'TABLE', N'tCsClCuentasNiveles', 'COLUMN', N'Longitud'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripcion del nivel', 'SCHEMA', N'dbo', 'TABLE', N'tCsClCuentasNiveles', 'COLUMN', N'DescNivel'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Desde el principio hasta este nivel', 'SCHEMA', N'dbo', 'TABLE', N'tCsClCuentasNiveles', 'COLUMN', N'LongitudTotal'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'S = Sistema (Oficinas y Fondos); U=(Usuario, definidos por el); L=(Ley, definidos por la SBEF)', 'SCHEMA', N'dbo', 'TABLE', N'tCsClCuentasNiveles', 'COLUMN', N'TipoNivel'
GO