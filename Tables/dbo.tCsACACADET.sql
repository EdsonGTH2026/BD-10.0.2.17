CREATE TABLE [dbo].[tCsACACADET] (
  [fecha] [smalldatetime] NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](30) NULL,
  [nombrecompleto] [varchar](300) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [estado] [varchar](50) NULL,
  [SaldoPonerCorriente] [money] NULL,
  [saldocapital] [money] NULL,
  [saldototal] [money] NULL,
  [promotor] [varchar](300) NULL,
  [Direccion] [varchar](100) NULL,
  [NumExt] [varchar](10) NULL,
  [Colonia] [varchar](60) NULL,
  [CodPostal] [varchar](10) NULL,
  [DirMunicipio] [varchar](60) NULL,
  [DirEstado] [varchar](60) NULL,
  [telefonomovil] [varchar](15) NULL,
  [telefonocasa] [varchar](15) NULL,
  [fechadesembolso] [smalldatetime] NULL,
  [fechavencimiento] [smalldatetime] NULL,
  [montodesembolso] [money] NULL,
  [ciclo] [int] NULL,
  [nrocuotas] [int] NULL,
  [modalidadplazo] [varchar](2) NULL,
  [TipoReprog] [varchar](10) NULL,
  [F_PROXIMO_CORTE] [smalldatetime] NULL,
  [DIA_DE_PAGO] [varchar](10) NULL,
  [cuota_programada] [money] NULL,
  [bi_nroregistros] [int] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACACADET] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsACACADET] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsACACADET] TO [jarriagaa]
GO