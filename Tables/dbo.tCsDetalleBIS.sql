CREATE TABLE [dbo].[tCsDetalleBIS] (
  [CodOficina] [varchar](4) NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [AsesorActual] [varchar](15) NOT NULL,
  [Ingreso] [smalldatetime] NOT NULL,
  [Salida] [smalldatetime] NULL,
  [AsesorAnterior] [varchar](15) NULL,
  [AtrasoInicial] [int] NULL,
  [BIS] [int] NULL,
  [BI] [int] NULL,
  [BF] [int] NULL,
  [InicioBIS] [smalldatetime] NULL,
  [FinBIS] [smalldatetime] NULL,
  [BisActivo] [bit] NULL,
  [AtrasoFinal] [int] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsDetalleBIS] PRIMARY KEY CLUSTERED ([CodPrestamo], [AsesorActual], [Ingreso])
)
ON [PRIMARY]
GO