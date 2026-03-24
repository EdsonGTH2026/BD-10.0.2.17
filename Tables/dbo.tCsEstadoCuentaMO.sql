CREATE TABLE [dbo].[tCsEstadoCuentaMO] (
  [Sistema] [varchar](2) NOT NULL,
  [Cuenta] [varchar](25) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [SecPago] [int] NOT NULL,
  [CodConcepto] [varchar](6) NOT NULL,
  [Concepto] [varchar](2087) NULL,
  [Cargo] [decimal](38, 4) NOT NULL,
  [Abono] [decimal](38, 4) NULL,
  [ConceptoD] [varchar](3000) NOT NULL,
  [CargoD] [decimal](38, 4) NOT NULL,
  [AbonoD] [decimal](38, 4) NULL,
  [SaldoAnterior] [decimal](20, 4) NULL,
  [SaldoActual] [decimal](20, 4) NULL,
  [Orden] [int] NOT NULL,
  CONSTRAINT [PK_tCsEstadoCuentaMO] PRIMARY KEY CLUSTERED ([Sistema], [Cuenta], [Fecha], [SecPago], [CodConcepto])
)
ON [PRIMARY]
GO