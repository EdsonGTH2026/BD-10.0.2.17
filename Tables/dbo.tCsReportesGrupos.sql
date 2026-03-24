CREATE TABLE [dbo].[tCsReportesGrupos] (
  [idGrupoRep] [smallint] NOT NULL,
  [CodNodo] [varchar](50) NOT NULL,
  [DescNodo] [varchar](150) NULL,
  [Nivel] [tinyint] NULL CONSTRAINT [DF_tCsReportesGrupos_Nivel] DEFAULT (0),
  [idReporte] [smallint] NULL,
  CONSTRAINT [PK_tCsReportesGrupos] PRIMARY KEY CLUSTERED ([idGrupoRep], [CodNodo])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'id del Grupo de Reporte', 'SCHEMA', N'dbo', 'TABLE', N'tCsReportesGrupos', 'COLUMN', N'idGrupoRep'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo nodo del Reporte', 'SCHEMA', N'dbo', 'TABLE', N'tCsReportesGrupos', 'COLUMN', N'CodNodo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripción del reporte', 'SCHEMA', N'dbo', 'TABLE', N'tCsReportesGrupos', 'COLUMN', N'DescNodo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nivel del Nodo', 'SCHEMA', N'dbo', 'TABLE', N'tCsReportesGrupos', 'COLUMN', N'Nivel'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'id del Reporte Asociado', 'SCHEMA', N'dbo', 'TABLE', N'tCsReportesGrupos', 'COLUMN', N'idReporte'
GO