CREATE TABLE [dbo].[tCsRptOpeMay30mil] (
  [fecha] [smalldatetime] NOT NULL,
  [codigocuenta] [varchar](25) NOT NULL,
  [codsistema] [char](2) NOT NULL,
  [codoficina] [varchar](4) NOT NULL,
  [nrotransaccion] [varchar](10) NOT NULL,
  [tipotransacnivel1] [char](1) NOT NULL,
  [tipotransacnivel3] [tinyint] NOT NULL,
  [nombrecliente] [varchar](200) NULL,
  [descripciontran] [varchar](1000) NULL,
  [montocapitaltran] [money] NULL,
  [montointerestran] [money] NULL,
  [montoinpetran] [money] NULL,
  [montocargos] [money] NULL,
  [montootrostran] [money] NULL,
  [montoimpuestos] [money] NULL,
  [montototaltran] [money] NULL
)
ON [PRIMARY]
GO