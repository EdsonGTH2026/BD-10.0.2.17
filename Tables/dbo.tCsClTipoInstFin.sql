CREATE TABLE [dbo].[tCsClTipoInstFin] (
  [CodTipoInstFin] [varchar](3) NOT NULL,
  [TipoInstFinNom] [varchar](150) NOT NULL,
  CONSTRAINT [PK_tCsClTipoInstFin] PRIMARY KEY CLUSTERED ([CodTipoInstFin])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Almacenará los tipo de instituciones bancarias y otros organismos que despliegan los reportes regulatorios para FIMEDER.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClTipoInstFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del tipo de institución financiera', 'SCHEMA', N'dbo', 'TABLE', N'tCsClTipoInstFin', 'COLUMN', N'CodTipoInstFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la institución financiera', 'SCHEMA', N'dbo', 'TABLE', N'tCsClTipoInstFin', 'COLUMN', N'TipoInstFinNom'
GO