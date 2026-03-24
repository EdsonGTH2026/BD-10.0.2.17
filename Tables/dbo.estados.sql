CREATE TABLE [dbo].[estados] (
  [id] [int] NOT NULL,
  [clave] [varchar](2) NOT NULL,
  [nombre] [varchar](40) NOT NULL,
  [abrev] [varchar](10) NOT NULL,
  [activo] [tinyint] NOT NULL DEFAULT (1)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[estados] TO [aperezp]
GO