CREATE TABLE [dbo].[tCsTCFacturaIntegra] (
  [idFactura] [numeric](10) NOT NULL,
  [codoficina] [varchar](4) NOT NULL,
  [CodTipoFactura] [varchar](5) NOT NULL,
  [item] [int] NOT NULL,
  [codsistema] [varchar](5) NULL,
  [codtipoopera] [varchar](15) NULL,
  [descripconcepto] [varchar](200) NULL,
  [fechaoriginal] [smalldatetime] NULL,
  [monto] [decimal](10, 2) NULL,
  [impuesto] [decimal](10, 2) NULL,
  [total] [decimal](10, 2) NULL,
  [coddato1] [varchar](50) NULL,
  [coddato2] [varchar](50) NULL,
  CONSTRAINT [PK_tCsTCFacturaIntegra] PRIMARY KEY CLUSTERED ([idFactura], [codoficina], [CodTipoFactura], [item])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsTCFacturaIntegra] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsTCFacturaIntegra_tCsTcFactura] FOREIGN KEY ([idFactura], [codoficina], [CodTipoFactura]) REFERENCES [dbo].[tCsTcFactura] ([idFactura], [codoficina], [CodTipoFactura]) ON DELETE CASCADE ON UPDATE CASCADE
GO