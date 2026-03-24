CREATE TABLE [dbo].[tCsTCFacturaDet] (
  [idFactura] [numeric](10) NOT NULL,
  [codoficina] [varchar](4) NOT NULL,
  [CodTipoFactura] [varchar](5) NOT NULL,
  [item] [int] NOT NULL,
  [codsistema] [varchar](5) NULL,
  [desconcepto] [varchar](200) NULL,
  [monto] [decimal](10, 2) NULL,
  [impuesto] [decimal](10, 2) NULL,
  [total] [decimal](10, 2) NULL,
  [Cantidad] [int] NULL,
  CONSTRAINT [PK_tCsTCFacturaDet] PRIMARY KEY CLUSTERED ([idFactura], [codoficina], [CodTipoFactura], [item])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsTCFacturaDet] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsTCFacturaDet_tCsTcFactura] FOREIGN KEY ([idFactura], [codoficina], [CodTipoFactura]) REFERENCES [dbo].[tCsTcFactura] ([idFactura], [codoficina], [CodTipoFactura]) ON DELETE CASCADE ON UPDATE CASCADE
GO