CREATE TABLE [dbo].[tCsPagoDet] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [SecPago] [int] NOT NULL,
  [SecCuota] [tinyint] NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [MontoPagado] [money] NULL CONSTRAINT [DF_tCsPagoDet_MontoPagado] DEFAULT (0),
  [OficinaTransaccion] [varchar](4) NOT NULL CONSTRAINT [DF_tCsPagoDet_CodOficina] DEFAULT (''),
  [Extornado] [bit] NULL,
  CONSTRAINT [PK_tCsPagoDet] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodPrestamo], [SecPago], [SecCuota], [CodConcepto], [CodUsuario], [OficinaTransaccion])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de la forma en que fue afectado un préstamo durante una recuperación', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la oficina donde se realizó la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Secuencial del pago', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'SecPago'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Secuencial de la cuota', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'SecCuota'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Concepto afectado', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'CodConcepto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Usuario afectado', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto pagado del concepto, cuota y usuario en cuestión', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'MontoPagado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la oficina donde se realizó la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsPagoDet', 'COLUMN', N'OficinaTransaccion'
GO