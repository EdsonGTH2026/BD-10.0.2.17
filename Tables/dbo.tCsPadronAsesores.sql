CREATE TABLE [dbo].[tCsPadronAsesores] (
  [CodAsesor] [char](15) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Consolidado] [smalldatetime] NULL,
  [FechaInicio] [smalldatetime] NULL,
  [NomAsesor] [varchar](80) NULL,
  [FechaFin] [smalldatetime] NULL,
  [ActivoActual] [bit] NULL,
  [Activo] [bit] NULL CONSTRAINT [DF_tCsPadronAsesores_Activo] DEFAULT (1),
  CONSTRAINT [PK_tCsPadronAsesores] PRIMARY KEY CLUSTERED ([CodAsesor])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Asesor', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronAsesores', 'COLUMN', N'CodAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la oficina', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronAsesores', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de inicio de actividades en agencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronAsesores', 'COLUMN', N'FechaInicio'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del Asesor', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronAsesores', 'COLUMN', N'NomAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de conclusion de actividades en agencia si ya no esta mas.', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronAsesores', 'COLUMN', N'FechaFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Si el asesor esta activo o no.', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronAsesores', 'COLUMN', N'Activo'
GO