CREATE TABLE [dbo].[tAhIntPeriodicos] (
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [NroPago] [int] NOT NULL,
  [Fecha] [datetime] NULL,
  [Monto] [money] NULL,
  [Impuesto] [money] NULL,
  [NroDias] [int] NULL,
  [IdEstadoCta] [varchar](2) NOT NULL,
  [TipoPago] [varchar](3) NULL,
  [FechaPagado] [datetime] NULL,
  [FechaReal] [datetime] NULL
)
ON [PRIMARY]
GO