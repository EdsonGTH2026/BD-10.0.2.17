CREATE TABLE [dbo].[tCaProdInteres] (
  [CodProducto] [char](3) NOT NULL,
  [TasaFija] [bit] NULL,
  [TasaVariable] [bit] NULL,
  [TasaVariableTiempo] [int] NULL,
  [UnidadTiempo] [char](2) NULL,
  [Iniforme] [bit] NULL,
  [SobreSaldo] [bit] NULL,
  [Descontado] [bit] NULL,
  [Capitalizable] [bit] NULL,
  [Concesional] [bit] NULL,
  [NoConcesional] [bit] NULL,
  [Preferencial] [bit] NULL,
  [Spread] [money] NULL,
  [Descuento] [bit] NULL
)
ON [PRIMARY]
GO