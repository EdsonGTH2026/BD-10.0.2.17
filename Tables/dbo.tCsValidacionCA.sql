CREATE TABLE [dbo].[tCsValidacionCA] (
  [Tipo] [varchar](50) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [SaldoCapital] [decimal](38, 4) NULL,
  [InteresVigente] [decimal](38, 4) NULL,
  [InteresVencido] [decimal](38, 4) NULL,
  [MoratorioVigente] [decimal](38, 4) NULL,
  [MoratorioVencido] [decimal](38, 4) NULL,
  [SaldoCartera] [decimal](38, 4) NULL,
  [InteresCtaOrden] [decimal](38, 4) NULL,
  [MoratorioCtaOrden] [decimal](38, 4) NULL,
  [SaldoInteres] [decimal](38, 4) NULL,
  [SaldoMoratorio] [decimal](38, 4) NULL,
  [OtrosCargos] [decimal](38, 4) NULL,
  [CargoMora] [decimal](38, 4) NULL,
  [Impuestos] [decimal](38, 4) NULL,
  [SaldoDeudor] [decimal](38, 4) NULL,
  [Signo] [int] NULL
)
ON [PRIMARY]
GO