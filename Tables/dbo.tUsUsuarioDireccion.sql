CREATE TABLE [dbo].[tUsUsuarioDireccion] (
  [CodUsuario] [char](15) NOT NULL,
  [IdDireccion] [int] IDENTITY,
  [FamiliarNegocio] [char](1) NOT NULL CONSTRAINT [DF_tUsUsuarioDireccion_FamiliarNegocio] DEFAULT ('F'),
  [CentroPoblado] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioDireccion_CentroPoblado] DEFAULT (1),
  [CodUbiGeo] [varchar](6) NOT NULL,
  [Direccion] [varchar](150) NOT NULL,
  [NumExterno] [varchar](10) NULL,
  [NumInterno] [varchar](10) NULL,
  [Ubicacion] [varchar](150) NULL,
  [CodPostal] [varchar](10) NULL,
  [CodTipoProDirec] [char](3) NOT NULL,
  [EsPrincipal] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioDireccion_EsPrincipal] DEFAULT (1),
  [TiempoDirDesde] [smallint] NOT NULL CONSTRAINT [DF_tUsUsuarioDireccion_TiempoDirDesde] DEFAULT (0),
  [TiempoCiudad] [smallint] NOT NULL CONSTRAINT [DF_tUsUsuarioDireccion_TiempoCiudad] DEFAULT (0),
  [NomPropietario] [varchar](50) NULL,
  [Telefono] [varchar](20) NULL,
  [CodTipoProFono] [char](3) NOT NULL CONSTRAINT [DF_tUsUsuarioDireccion_CodTipoProFono] DEFAULT ('DES'),
  [Observaciones] [varchar](250) NULL,
  CONSTRAINT [PK_tUsUsuarioDireccion] PRIMARY KEY CLUSTERED ([CodUsuario], [IdDireccion])
)
ON [PRIMARY]
GO