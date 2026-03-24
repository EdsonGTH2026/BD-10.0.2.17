CREATE TABLE [dbo].[tCsACAReestructurasCCESeg] (
  [codprestamo] [varchar](19) NULL,
  [cliente] [varchar](200) NULL,
  [fechareprog] [smalldatetime] NULL,
  [fechavencimiento] [smalldatetime] NULL,
  [cuotas] [int] NULL,
  [codtipoplaz] [char](1) NULL,
  [codoficina] [varchar](3) NULL,
  [sucursal] [varchar](100) NULL,
  [region] [varchar](30) NULL,
  [conpagosostenido] [tinyint] NULL,
  [fechapagosostenido] [smalldatetime] NULL,
  [nropagosacum] [tinyint] NULL,
  [nrodiasatraso] [int] NULL,
  [proximovencimiento] [smalldatetime] NULL,
  [saldocuotaantigua] [money] NULL,
  [montocuotaprogramado] [money] NULL,
  [nrodiasatraso31] [int] NULL,
  [fechapago] [smalldatetime] NULL,
  [montopago] [money] NULL
)
ON [PRIMARY]
GO