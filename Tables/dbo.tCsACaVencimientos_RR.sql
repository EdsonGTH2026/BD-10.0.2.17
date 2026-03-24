CREATE TABLE [dbo].[tCsACaVencimientos_RR] (
  [fecha] [smalldatetime] NULL,
  [region] [varchar](50) NULL,
  [codoficina] [varchar](4) NOT NULL,
  [sucursal] [varchar](30) NULL,
  [coordinador] [varchar](300) NULL,
  [cliente] [varchar](300) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [secuenciacliente] [int] NULL,
  [monto] [decimal](18, 4) NULL,
  [fechadesembolso] [smalldatetime] NULL,
  [fechavencimiento] [smalldatetime] NULL,
  [cancelacion] [smalldatetime] NULL,
  [atrasomaximo] [int] NULL,
  [Estado] [varchar](15) NOT NULL,
  [nuevomonto] [decimal](18, 4) NULL,
  [nuevodesembolso] [smalldatetime] NULL,
  [codprestamonuevo] [varchar](25) NULL,
  [Deuda] [money] NULL
)
ON [PRIMARY]
GO