CREATE TABLE [dbo].[tCsClPonderacionActivo] (
  [IdPonderacion] [int] NOT NULL,
  [CodCta] [varchar](25) NOT NULL,
  [CodFondo] [varchar](2) NOT NULL,
  [GrupoReporteRiesgo] [char](1) NOT NULL,
  [SeccionReporte] [varchar](3) NOT NULL,
  [PorcPonderacion] [money] NOT NULL,
  CONSTRAINT [PK_tCsClPonderacionActivo] PRIMARY KEY CLUSTERED ([IdPonderacion])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ALmacena la ponderación de activos para los reportes regulatorios de FIMEDER.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClPonderacionActivo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta contable', 'SCHEMA', N'dbo', 'TABLE', N'tCsClPonderacionActivo', 'COLUMN', N'CodCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del Fondo', 'SCHEMA', N'dbo', 'TABLE', N'tCsClPonderacionActivo', 'COLUMN', N'CodFondo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Grupo del reporte al que pertenece la ponderación', 'SCHEMA', N'dbo', 'TABLE', N'tCsClPonderacionActivo', 'COLUMN', N'GrupoReporteRiesgo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Seccion dentro del grupo del reporte al que pertenece la ponderación', 'SCHEMA', N'dbo', 'TABLE', N'tCsClPonderacionActivo', 'COLUMN', N'SeccionReporte'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Porcentaje de ponderación', 'SCHEMA', N'dbo', 'TABLE', N'tCsClPonderacionActivo', 'COLUMN', N'PorcPonderacion'
GO