CREATE TABLE [dbo].[tCsCaSaldosCuotas] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [char](19) NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [DiasMora] [smallint] NULL CONSTRAINT [DF_tCsCaSaldosCuotas_DiasMora] DEFAULT (0),
  [Estado] [varchar](25) NOT NULL,
  [MontoCuota] [money] NOT NULL CONSTRAINT [DF_tCsCaSaldosCuotas_MontoCuota] DEFAULT (0),
  [MontoPagado] [money] NULL CONSTRAINT [DF_tCsCaSaldosCuotas_MontoPagado] DEFAULT (0),
  [MontoDevengado] [money] NULL CONSTRAINT [DF_tCsCaSaldosCuotas_MontoDevengado] DEFAULT (0),
  [MontoCondonado] [money] NULL CONSTRAINT [DF_tCsCaSaldosCuotas_MontoCondonado] DEFAULT (0),
  [MontoDevengadoAnt] [money] NULL CONSTRAINT [DF_tCsCaSaldosCuotas_MontoDevengadoAnt] DEFAULT (0),
  [MontoVigente] [money] NULL CONSTRAINT [DF_tCsCaSaldosCuotas_MontoVigente] DEFAULT (0),
  CONSTRAINT [PK_tCsCaSaldosCuotas] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo], [CodConcepto])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha en donde se proceso el crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de prestamo', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Concepto', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'CodConcepto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Oficina', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Dias de Mora del crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'DiasMora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de la Cuota', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'MontoCuota'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto Pagado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'MontoPagado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto Devengado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'MontoDevengado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto Condonado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'MontoCondonado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto Devengado Anterior', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'MontoDevengadoAnt'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto Congelado Vigente', 'SCHEMA', N'dbo', 'TABLE', N'tCsCaSaldosCuotas', 'COLUMN', N'MontoVigente'
GO