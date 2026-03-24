CREATE TABLE [dbo].[Saldos1] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [Concepto] [varchar](100) NULL,
  [SaldoCapital] [money] NULL,
  [InteresOrdinario] [money] NULL,
  [InteresMoratorio] [money] NULL,
  [OtrosCargos] [money] NULL,
  [ComisionIVA] [money] NULL
)
ON [PRIMARY]
GO