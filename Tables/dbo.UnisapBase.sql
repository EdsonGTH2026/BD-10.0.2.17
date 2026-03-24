CREATE TABLE [dbo].[UnisapBase] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodUsuario] [varchar](25) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [Nombre] [varchar](80) NULL,
  [Nacimiento] [smalldatetime] NULL,
  [RFC] [varchar](20) NULL,
  [Direccion] [varchar](150) NULL,
  [Colonia] [varchar](60) NULL,
  [DelMun] [varchar](150) NULL,
  [Estado] [varchar](4) NULL,
  [CP] [varchar](10) NULL,
  [TipoPrestamo] [varchar](10) NULL,
  [Cuotas] [smallint] NULL,
  [Monto] [decimal](38, 4) NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [FechaUltPago] [datetime] NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [DesembolsoUsuario] [decimal](16, 4) NULL,
  [Saldo] [decimal](23, 4) NULL,
  [DiasMora] [int] NULL,
  [CodUbigeo] [varchar](6) NULL,
  [EstadoPrestamo] [varchar](50) NULL,
  [Observacion] [varchar](83) NOT NULL
)
ON [PRIMARY]
GO