CREATE TABLE [dbo].[tSITILocalidad] (
  [Clave] [varchar](8) NOT NULL,
  [Estado] [varchar](255) NULL,
  [Localidad] [varchar](255) NULL,
  [Mexico] [bit] NULL,
  [EstadoPais] [varchar](10) NULL,
  CONSTRAINT [PK_tSITILocalidad] PRIMARY KEY CLUSTERED ([Clave])
)
ON [PRIMARY]
GO