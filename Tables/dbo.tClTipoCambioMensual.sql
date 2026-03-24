CREATE TABLE [dbo].[tClTipoCambioMensual] (
  [CodMoneda] [varchar](2) NOT NULL,
  [Gestion] [smallint] NOT NULL,
  [Mes] [tinyint] NOT NULL,
  [CompraOficial] [money] NOT NULL,
  [VentaOficial] [money] NOT NULL,
  [CompraPublico] [money] NOT NULL,
  [VentaPublico] [money] NOT NULL
)
ON [PRIMARY]
GO