CREATE TABLE [dbo].[tCsIntPeriodicos] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [NroPago] [int] NOT NULL,
  [FechaPago] [datetime] NULL,
  [Monto] [money] NULL,
  [Impuesto] [money] NULL,
  [NroDias] [int] NULL CONSTRAINT [DF_tCsIntPeriodicos_NroDias] DEFAULT (0),
  [IdEstadoCta] [varchar](2) NOT NULL CONSTRAINT [DF_tCsIntPeriodicos_IdEstadoCta] DEFAULT (0),
  [TipoPago] [varchar](3) NULL,
  [FechaPagado] [datetime] NULL,
  [FechaReal] [datetime] NULL,
  [PagoParcial] [money] NULL,
  CONSTRAINT [PK_tCsIntPeriodicos] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodCuenta], [FraccionCta], [Renovado], [NroPago])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsIntPeriodicos_CodCuenta_FraccionCta_Renovado_NroPago_TipoPago]
  ON [dbo].[tCsIntPeriodicos] ([CodCuenta], [FraccionCta], [Renovado], [NroPago], [TipoPago])
  INCLUDE ([FechaPagado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsIntPeriodicos_CodCuenta_FraccionCta_Renovado_TipoPago]
  ON [dbo].[tCsIntPeriodicos] ([CodCuenta], [FraccionCta], [Renovado], [TipoPago])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Registra el plan de pagos de los intereses en los Depósitos a Plazo Fijo.', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de pago', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'CodCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de fraccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'FraccionCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de renovaciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'Renovado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de pago de intereses', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'NroPago'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de pago', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'FechaPago'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de pago del interés', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'Monto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Valor del impuesto', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'Impuesto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de dias del pago', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'NroDias'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del estado de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'IdEstadoCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de Pago q se realiZa, INT=Interes y CAP=Capital', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'TipoPago'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de realiZacion del pago', 'SCHEMA', N'dbo', 'TABLE', N'tCsIntPeriodicos', 'COLUMN', N'FechaPagado'
GO