CREATE TABLE [dbo].[tCaClModalidadPlazo] (
  [ModalidadPlazo] [char](1) NOT NULL,
  [Plazo] [smallint] NOT NULL,
  [Descripcion] [varchar](15) NOT NULL,
  [SHF] [tinyint] NULL,
  [INTF] [char](1) NULL,
  [Modalidad] [varchar](100) NULL,
  [Singular] [varchar](50) NULL,
  [Plural] [varchar](50) NULL,
  [FactorMensual] [money] NULL,
  [FactorAnual] [money] NULL,
  [plazofin] [smallint] NULL,
  [plazoini] [smallint] NULL,
  CONSTRAINT [PK_tCaClModalidadPlazo] PRIMARY KEY CLUSTERED ([ModalidadPlazo])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaClModalidadPlazo] TO [jarriagaa]
GO

GRANT SELECT ON [dbo].[tCaClModalidadPlazo] TO [public]
GO