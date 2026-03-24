CREATE TABLE [dbo].[tCsTcFactura] (
  [idFactura] [numeric](10) NOT NULL,
  [codoficina] [varchar](4) NOT NULL,
  [CodTipoFactura] [varchar](5) NOT NULL,
  [serie] [varchar](15) NULL,
  [folio] [varchar](15) NULL,
  [nroaprobacion] [varchar](15) NULL,
  [añoaprobacion] [int] NULL,
  [nroseriecerti] [varchar](50) NULL,
  [codusuario] [varchar](15) NULL,
  [RFC] [varchar](15) NULL,
  [IVA] [decimal](10, 2) NULL,
  [subtotal] [decimal](10, 2) NULL,
  [total] [decimal](10, 2) NULL,
  [cadoriginal] [varchar](2000) NULL,
  [sellodigital] [varchar](2000) NULL,
  [estado] [char](1) NULL,
  [esautomatica] [char](1) NULL,
  [fecha] [smalldatetime] NULL,
  [nombrefactura] [varchar](300) NULL,
  [textoxml] [text] NULL,
  CONSTRAINT [PK_tCsTcFactura] PRIMARY KEY CLUSTERED ([idFactura], [codoficina], [CodTipoFactura])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE INDEX [IX_tCsTcFactura]
  ON [dbo].[tCsTcFactura] ([codoficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsTcFactura_1]
  ON [dbo].[tCsTcFactura] ([fecha])
  ON [PRIMARY]
GO