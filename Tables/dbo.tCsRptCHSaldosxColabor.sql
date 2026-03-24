CREATE TABLE [dbo].[tCsRptCHSaldosxColabor] (
  [fecha] [smalldatetime] NULL,
  [tipo] [varchar](100) NULL,
  [region] [varchar](200) NULL,
  [sucursal] [varchar](200) NULL,
  [nroclientes] [decimal](16, 2) NULL,
  [saldocartera] [decimal](16, 2) NULL,
  [nropromotores] [decimal](16, 2) NULL,
  [nroempleados] [decimal](16, 2) NULL,
  [npxclientes] [decimal](16, 2) NULL,
  [nexclientes] [decimal](16, 2) NULL,
  [npxsaldocartera] [decimal](16, 2) NULL,
  [nexsaldocartera] [decimal](16, 2) NULL,
  [imor] [decimal](16, 2) NULL,
  [npximor] [decimal](16, 2) NULL,
  [neximor] [decimal](16, 2) NULL
)
ON [PRIMARY]
GO