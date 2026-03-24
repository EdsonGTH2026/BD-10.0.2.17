CREATE TABLE [dbo].[tCsACAInpagos_2] (
  [fecha] [smalldatetime] NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](30) NULL,
  [nombrecompleto] [varchar](300) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [SaldoPonerCorriente] [money] NULL,
  [saldototal] [money] NULL,
  [promotor] [varchar](300) NULL,
  [Direccion] [varchar](100) NULL,
  [N° Ext.] [varchar](8000) NULL,
  [Colonia] [varchar](60) NULL,
  [CodPostal] [varchar](10) NULL,
  [Municipio] [varchar](60) NULL,
  [Estado] [varchar](60) NULL,
  [telefonomovil] [varchar](50) NULL,
  [telefonocasa] [varchar](20) NULL
)
ON [PRIMARY]
GO