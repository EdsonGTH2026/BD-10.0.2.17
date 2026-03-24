CREATE TABLE [dbo].[tCsAAhAperturas] (
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](200) NULL,
  [codproducto] [varchar](3) NULL,
  [Abreviatura] [varchar](200) NULL,
  [NombreCliente] [varchar](200) NULL,
  [codcuenta] [varchar](25) NULL,
  [fraccioncta] [varchar](2) NULL,
  [renovado] [int] NULL,
  [fecapertura] [smalldatetime] NULL,
  [FechaCierre] [smalldatetime] NULL,
  [saldocuenta] [money] NULL,
  [TasaInteres] [money] NULL,
  [Plazo] [int] NULL
)
ON [PRIMARY]
GO