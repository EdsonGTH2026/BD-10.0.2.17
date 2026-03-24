CREATE TABLE [dbo].[tCsACALiqui] (
  [sucursal] [varchar](30) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [nombrecompleto] [varchar](300) NULL,
  [cancelacion] [smalldatetime] NULL,
  [coordinador] [varchar](300) NULL,
  [montoanterior] [decimal](18, 4) NULL,
  [estado] [varchar](50) NULL,
  [nrodiasatraso] [int] NULL,
  [SecuenciaProductivo] [int] NULL,
  [SecuenciaConsumo] [int] NULL,
  [EstadoPromotor] [varchar](6) NOT NULL,
  [nuevodesembolso] [smalldatetime] NULL,
  [nuevoprestamo] [varchar](25) NOT NULL,
  [telefonomovil] [varchar](15) NULL
)
ON [PRIMARY]
GO