CREATE TABLE [dbo].[tmpCaptacion_110321] (
  [NumContrato] [varchar](37) NULL,
  [CodTipoInteres] [smallint] NULL,
  [tasainteres] [money] NULL,
  [Plazo] [numeric](10) NULL,
  [s1] [money] NOT NULL,
  [i1] [money] NOT NULL,
  ['+ SaldoInicioPeriodo(s1+i1)] [money] NULL,
  [SaldoBruto(SB)] [money] NULL,
  [intacumulado(IA)] [money] NULL,
  ['+ MontoDesposito] [money] NOT NULL,
  ['- MontoRetiro] [money] NOT NULL,
  ['+ InteresDevengado] [money] NULL,
  [SaldoFinalPeriodo(SB+IA)] [money] NULL,
  [ISR] [money] NOT NULL,
  [SalCalc] [money] NULL,
  [DifCalc] [money] NULL,
  [NumTransIguales] [varchar](10) NULL,
  [TransEdo] [int] NULL,
  [NumPagInt] [int] NULL,
  [MontoPagInt] [money] NULL
)
ON [PRIMARY]
GO