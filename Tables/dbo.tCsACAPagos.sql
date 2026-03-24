CREATE TABLE [dbo].[tCsACAPagos] (
  [fecha] [smalldatetime] NULL,
  [codorigenpago] [varchar](15) NULL,
  [codprestamo] [varchar](25) NULL,
  [sucursal] [varchar](250) NULL,
  [nrodiasatraso] [int] NULL,
  [nro] [int] NULL,
  [total] [money] NULL,
  [capital] [money] NULL,
  [capitalprogre] [numeric](38, 5) NULL,
  [capitalCubo] [numeric](38, 6) NULL,
  [capitalpropio] [numeric](38, 6) NULL,
  [interes] [money] NULL,
  [interesProgresemos] [numeric](38, 5) NULL,
  [interesCubo] [numeric](38, 6) NULL,
  [interesPropio] [numeric](38, 6) NULL,
  [cargos] [money] NULL,
  [seguros] [money] NULL,
  [cargosIVA] [numeric](38, 6) NULL,
  [IVAinteres] [numeric](38, 6) NULL,
  [IVAinteresProgresemos] [numeric](38, 7) NULL,
  [IVAinteresCubo] [numeric](38, 8) NULL,
  [IVAinteresPropio] [numeric](38, 8) NULL
)
ON [PRIMARY]
GO