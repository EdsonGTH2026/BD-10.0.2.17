CREATE TABLE [dbo].[tCsClientesObservaciones] (
  [Observacion] [varchar](2) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [OOrigen] [varchar](4) NULL,
  [OAhorros] [varchar](4) NULL,
  [OCreditos] [varchar](4) NULL,
  [CodCuenta] [varchar](25) NULL,
  [CodPrestamo] [varchar](25) NULL,
  [Detalle] [varchar](500) NULL,
  [Prioridad] [int] NULL,
  [ROrigen] [varchar](100) NULL,
  [RAhorros] [varchar](100) NULL,
  [RCreditos] [varchar](100) NULL,
  [Responsable] [varchar](100) NULL,
  [CodOficina] [varchar](4) NULL
)
ON [PRIMARY]
GO