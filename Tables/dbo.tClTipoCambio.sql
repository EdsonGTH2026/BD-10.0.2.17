CREATE TABLE [dbo].[tClTipoCambio] (
  [CodMoneda] [varchar](2) NOT NULL,
  [FechTC] [smalldatetime] NOT NULL,
  [CompraOficial] [smallmoney] NOT NULL,
  [VentaOficial] [smallmoney] NOT NULL,
  [CompraPublico] [smallmoney] NOT NULL,
  [VentaPublico] [smallmoney] NULL,
  [EstTipoCamb] [varchar](10) NULL,
  [TFijo] [smallmoney] NOT NULL,
  [MantValor] [smallmoney] NULL
)
ON [PRIMARY]
GO