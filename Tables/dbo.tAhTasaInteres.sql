CREATE TABLE [dbo].[tAhTasaInteres] (
  [idProducto] [int] NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [CodOficina] [varchar](5) NOT NULL,
  [CodTipoInteres] [smallint] NOT NULL,
  [idTasa] [int] NOT NULL,
  [Tasa] [money] NULL,
  [TasaMin] [money] NULL,
  [TasaMax] [money] NULL,
  [MontoMin] [money] NULL,
  [MontoMax] [money] NULL,
  [PlazoIni] [int] NULL,
  [PlazoFin] [int] NULL,
  [idEstado] [char](2) NULL,
  CONSTRAINT [PK_tAhTasaInteres] PRIMARY KEY CLUSTERED ([idProducto], [CodMoneda], [CodOficina], [CodTipoInteres], [idTasa])
)
ON [PRIMARY]
GO