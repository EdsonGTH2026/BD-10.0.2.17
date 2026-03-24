CREATE TABLE [dbo].[tCsADatosCliCarteraActiva] (
  [fecha] [smalldatetime] NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [NombreCliente] [varchar](300) NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](30) NULL,
  [codproducto] [smallint] NULL,
  [FechaOtorgamiento] [varchar](54) NULL,
  [FechaVencimiento] [varchar](54) NULL,
  [MontoDesembolsoFondeador] [numeric](21, 5) NULL,
  [MontoDesembolsoTotal] [money] NULL,
  [estadocredito] [varchar](50) NULL,
  [nrodiasatraso] [int] NULL,
  [codfondo] [tinyint] NULL,
  [saldocapital] [money] NOT NULL,
  [interesvigente] [money] NULL,
  [interesvencido] [money] NULL,
  [interesctaorden] [money] NULL,
  [moratoriovigente] [money] NULL,
  [moratoriovencido] [money] NULL,
  [moratorioctaorden] [money] NULL,
  [cargomora] [money] NULL,
  [otroscargos] [money] NOT NULL,
  [impuestos] [money] NULL,
  [nombre_coordinador] [varchar](300) NULL,
  [nombre_verificador] [varchar](300) NULL,
  [TasaIntCorriente] [decimal](18, 7) NULL,
  [nrocuotas] [smallint] NULL,
  [Frecuencia] [varchar](15) NULL,
  [PlazoCredito] [int] NULL,
  [proximovencimiento] [smalldatetime] NULL,
  [telefonomovil] [varchar](50) NULL,
  [genero] [bit] NULL,
  [Direccion] [varchar](100) NULL,
  [NUMERO] [varchar](8000) NULL,
  [COLONIA] [varchar](60) NULL,
  [CodPostal] [varchar](10) NULL,
  [MUNICIPIO] [varchar](60) NULL,
  [ESTADO] [varchar](60) NULL,
  [coordinadorEstado] [varchar](8) NOT NULL,
  [SaldoPonerCorriente] [money] NULL,
  [secuenciacliente] [int] NULL,
  [fechanacimiento] [smalldatetime] NULL,
  [edad] [int] NULL,
  [fechaultimomovimiento] [smalldatetime] NULL,
  [nrocuotaspagadas] [int] NULL,
  [cuotasvencidas] [int] NULL,
  [cuotasxvencer] [int] NULL,
  [montoamortiza] [money] NULL,
  [Tiporeprog] [varchar](10) NULL,
  [DIA_DE_PAGO] [varchar](10) NULL,
  [bi_nroregistros] [int] NULL,
  [destino] [varchar](50) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsADatosCliCarteraActiva_codprestamo]
  ON [dbo].[tCsADatosCliCarteraActiva] ([codprestamo])
  INCLUDE ([SaldoPonerCorriente])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsADatosCliCarteraActiva] TO [Int_dreyesg]
GO