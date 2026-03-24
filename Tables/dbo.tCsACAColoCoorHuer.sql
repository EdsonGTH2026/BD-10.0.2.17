CREATE TABLE [dbo].[tCsACAColoCoorHuer] (
  [fecha] [smalldatetime] NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [desembolso] [smalldatetime] NULL,
  [monto] [decimal](18, 4) NULL,
  [cancelacion] [smalldatetime] NULL,
  [coordinador] [varchar](300) NULL,
  [sucursal] [varchar](30) NULL,
  [tipo] [varchar](8) NOT NULL,
  [codprestamo_ante] [varchar](25) NULL,
  [monto_ante] [decimal](18, 4) NULL,
  [tipo_ante] [varchar](8) NOT NULL,
  [coordinador_ante] [varchar](300) NULL,
  [ingreso] [smalldatetime] NULL,
  [secuenciacliente] [int] NULL
)
ON [PRIMARY]
GO