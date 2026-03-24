CREATE TABLE [dbo].[municipios] (
  [id] [int] NOT NULL,
  [estado_id] [int] NOT NULL,
  [clave] [varchar](3) NOT NULL,
  [nombre] [varchar](100) NOT NULL,
  [activo] [tinyint] NOT NULL DEFAULT (1)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[municipios] TO [aperezp]
GO