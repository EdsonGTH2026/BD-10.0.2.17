CREATE TABLE [dbo].[C] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [Concepto] [varchar](100) NULL,
  [ASaldoCapital] [money] NULL,
  [AInteresOrdinario] [money] NULL,
  [AInteresMoratorio] [money] NULL,
  [AOtrosCargos] [money] NULL,
  [AComisionIVA] [money] NULL
)
ON [PRIMARY]
GO