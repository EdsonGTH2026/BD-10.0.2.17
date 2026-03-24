CREATE TABLE [dbo].[localidades] (
  [id] [int] NOT NULL,
  [municipio_id] [int] NOT NULL,
  [clave] [varchar](4) NOT NULL,
  [nombre] [varchar](100) NOT NULL,
  [mapa] [int] NOT NULL,
  [ambito] [char](1) NOT NULL,
  [latitud] [varchar](20) NOT NULL,
  [longitud] [varchar](20) NOT NULL,
  [lat] [decimal](10, 7) NOT NULL,
  [lng] [decimal](10, 7) NOT NULL,
  [altitud] [varchar](15) NOT NULL,
  [carta] [varchar](10) NOT NULL,
  [poblacion] [int] NOT NULL,
  [masculino] [int] NOT NULL,
  [femenino] [int] NOT NULL,
  [viviendas] [int] NOT NULL,
  [activo] [tinyint] NOT NULL DEFAULT (1)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[localidades] TO [aperezp]
GO