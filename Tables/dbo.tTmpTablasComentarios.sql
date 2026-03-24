CREATE TABLE [dbo].[tTmpTablasComentarios] (
  [Tabla] [varchar](50) NULL,
  [objtype] [varchar](128) NULL,
  [objname] [varchar](128) NULL,
  [name] [varchar](128) NOT NULL,
  [value] [sql_variant] NULL
)
ON [PRIMARY]
GO