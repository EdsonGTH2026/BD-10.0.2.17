CREATE TABLE [dbo].[tCCDomicilios] (
  [RFC] [varchar](13) NOT NULL,
  [item] [int] NOT NULL,
  [Direccion] [varchar](80) NULL,
  [ColoniaPoblacion] [varchar](65) NULL,
  [DelegacionMunicipio] [varchar](65) NULL,
  [Ciudad] [varchar](65) NULL,
  [Estado] [varchar](4) NULL,
  [CP] [varchar](5) NULL,
  [FechaResidencia] [smalldatetime] NULL,
  [NumeroTelefono] [varchar](20) NULL,
  [TipoDomicilio] [char](1) NULL,
  [TipoAsentamiento] [varchar](2) NULL,
  [FechaRegistro] [smalldatetime] NULL
)
ON [PRIMARY]
GO