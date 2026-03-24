CREATE TABLE [dbo].[tCsAsesores] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodAsesor] [char](15) NOT NULL,
  [FechaInicio] [smalldatetime] NULL,
  [NomAsesor] [varchar](80) NULL,
  [FechaFin] [smalldatetime] NULL,
  [Activo] [bit] NULL CONSTRAINT [DF_tCsAsesores_Activo] DEFAULT (1),
  CONSTRAINT [PK_tCsAsesores] PRIMARY KEY CLUSTERED ([CodOficina], [CodAsesor])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la oficina', 'SCHEMA', N'dbo', 'TABLE', N'tCsAsesores', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Asesor', 'SCHEMA', N'dbo', 'TABLE', N'tCsAsesores', 'COLUMN', N'CodAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de inicio de actividades en agencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsAsesores', 'COLUMN', N'FechaInicio'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del Asesor', 'SCHEMA', N'dbo', 'TABLE', N'tCsAsesores', 'COLUMN', N'NomAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de conclusion de actividades en agencia si ya no esta mas.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAsesores', 'COLUMN', N'FechaFin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Si el asesor esta activo o no.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAsesores', 'COLUMN', N'Activo'
GO