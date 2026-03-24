CREATE TABLE [dbo].[tCsIntPeriodicosDetVariable] (
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [NroPago] [int] NOT NULL,
  [NumPeriodo] [int] NOT NULL,
  [FechaInicio] [datetime] NULL,
  [PorcentajePagar] [int] NULL,
  [PorcentajeReinvertir] [int] NULL,
  [CapitalInicialPeriodo] [money] NULL,
  [PagoAmortizacionCapital] [money] NULL,
  [DiasCalculados] [int] NULL,
  [InteresPeriodo] [money] NULL,
  [InteresPagar] [money] NULL,
  [InteresReinvertir] [money] NULL,
  [PagoNetoPeriodo] [money] NULL,
  [CapitalFinalPeriodo] [money] NULL
)
ON [PRIMARY]
GO