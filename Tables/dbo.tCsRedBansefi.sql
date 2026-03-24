CREATE TABLE [dbo].[tCsRedBansefi] (
  [Consecutivo] [float] NOT NULL,
  [ServicioUSA] [nvarchar](255) NULL,
  [ServicioMEX] [nvarchar](255) NULL,
  [CambioEnEdicion] [nvarchar](255) NULL,
  [ClaveEntidad] [float] NULL,
  [ClaveSucursal] [float] NULL,
  [Sucursal] [nvarchar](255) NULL,
  [Responsable] [nvarchar](255) NULL,
  [SociedadIntegrante] [nvarchar](255) NULL,
  [Telefono] [nvarchar](255) NULL,
  [UbigeoEstado] [nvarchar](255) NULL,
  [UbigeoMunicipio] [nvarchar](255) NULL,
  [UbigeoLocalidad] [nvarchar](255) NULL,
  [CodigoPostal] [nvarchar](255) NULL,
  [DescEstado] [nvarchar](255) NULL,
  [DescMunicipio] [nvarchar](255) NULL,
  [DescColonia] [nvarchar](255) NULL,
  [DescLocalidad] [nvarchar](255) NULL,
  [Direccion] [nvarchar](255) NULL,
  [HorarioLunesViernes] [nvarchar](255) NULL,
  [HorarioSabado] [nvarchar](255) NULL,
  [HorarioDomingo] [nvarchar](255) NULL,
  CONSTRAINT [PK_tCsBansefi] PRIMARY KEY CLUSTERED ([Consecutivo])
)
ON [PRIMARY]
GO