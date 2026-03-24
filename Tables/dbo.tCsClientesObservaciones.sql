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
  [CodOficina] AS ([OOrigen]),
  CONSTRAINT [PK_tCsClientesObservacionesw] PRIMARY KEY CLUSTERED ([Observacion], [Fecha], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesObservaciones]
  ON [dbo].[tCsClientesObservaciones] ([Fecha])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesObservaciones_1]
  ON [dbo].[tCsClientesObservaciones] ([CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesObservaciones_2]
  ON [dbo].[tCsClientesObservaciones] ([OOrigen])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesObservaciones_3]
  ON [dbo].[tCsClientesObservaciones] ([OAhorros])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesObservaciones_4]
  ON [dbo].[tCsClientesObservaciones] ([OCreditos])
  ON [PRIMARY]
GO