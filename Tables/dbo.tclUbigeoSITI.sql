CREATE TABLE [dbo].[tclUbigeoSITI] (
  [Segmento] [varchar](4) NULL,
  [Clave_Entidad] [varchar](4) NULL,
  [Nombre_Entidad] [varchar](300) NULL,
  [Clave_Municipio] [varchar](4) NULL,
  [IdMunicipio] [varchar](10) NULL,
  [Nombre_Municipio] [varchar](300) NULL,
  [Localidad] [varchar](5) NULL,
  [Clave_Localidad] [varchar](10) NOT NULL,
  [IdLocalidad] [varchar](10) NULL,
  [Nombre_Localidad] [varchar](300) NULL,
  [Poblacion_Total] [float] NULL,
  [Marginalidad] [varchar](20) NULL,
  CONSTRAINT [PK_tclUbigeoSITI] PRIMARY KEY CLUSTERED ([Clave_Localidad])
)
ON [PRIMARY]
GO