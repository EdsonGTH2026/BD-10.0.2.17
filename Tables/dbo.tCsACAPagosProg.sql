CREATE TABLE [dbo].[tCsACAPagosProg] (
  [Fecha_Prox_Pago] [smalldatetime] NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](100) NULL,
  [nombrecompleto] [varchar](300) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [SaldoPonerCorriente] [money] NULL,
  [saldototal] [money] NULL,
  [promotor] [varchar](300) NULL,
  [Direccion] [varchar](100) NULL,
  [N_Ext] [varchar](50) NULL,
  [Colonia] [varchar](100) NULL,
  [CodPostal] [varchar](10) NULL,
  [Municipio] [varchar](100) NULL,
  [Estado] [varchar](100) NULL,
  [telefonomovil] [varchar](15) NULL,
  [telefonocasa] [varchar](15) NULL
)
ON [PRIMARY]
GO