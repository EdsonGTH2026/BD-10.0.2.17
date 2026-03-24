CREATE TABLE [dbo].[tCsCarteraGrupos] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodGrupo] [varchar](15) NOT NULL,
  [NombreGrupo] [varchar](50) NOT NULL,
  CONSTRAINT [PK_tCsCarteraGrupos] PRIMARY KEY CLUSTERED ([CodOficina], [CodGrupo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCarteraGrupos]
  ON [dbo].[tCsCarteraGrupos] ([NombreGrupo])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de oficina', 'SCHEMA', N'dbo', 'TABLE', N'tCsCarteraGrupos', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de grupo', 'SCHEMA', N'dbo', 'TABLE', N'tCsCarteraGrupos', 'COLUMN', N'CodGrupo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'nombre del grupo', 'SCHEMA', N'dbo', 'TABLE', N'tCsCarteraGrupos', 'COLUMN', N'NombreGrupo'
GO