CREATE TABLE [dbo].[tCsClFondos] (
  [CodFondo] [tinyint] NOT NULL,
  [NemFondo] [varchar](15) NULL,
  CONSTRAINT [PK_tCsClFondos] PRIMARY KEY CLUSTERED ([CodFondo])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del Fondo', 'SCHEMA', N'dbo', 'TABLE', N'tCsClFondos', 'COLUMN', N'CodFondo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nemonico del fondo', 'SCHEMA', N'dbo', 'TABLE', N'tCsClFondos', 'COLUMN', N'NemFondo'
GO