CREATE TABLE [dbo].[tCsTransaccionDiaria] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodigoCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL CONSTRAINT [DF_tCsTransaccionDiaria_FraccionCta1] DEFAULT (0),
  [Renovado] [tinyint] NOT NULL CONSTRAINT [DF_tCsTransaccionDiaria_Renovado1] DEFAULT (0),
  [CodSistema] [char](2) NOT NULL,
  [TranHora] [char](2) NULL,
  [TranMinuto] [char](2) NULL,
  [TranSegundo] [char](2) NULL,
  [TranMicroSegundo] [smallint] NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodOficinaCuenta] [varchar](4) NULL,
  [NroTransaccion] [varchar](10) NOT NULL,
  [TipoTransacNivel1] [char](1) NOT NULL,
  [TipoTransacNivel2] [varchar](10) NOT NULL,
  [TipoTransacNivel3] [tinyint] NOT NULL,
  [Extornado] [bit] NULL CONSTRAINT [DF_tCsTransaccionDiaria_Extornado1] DEFAULT (0),
  [TipoCambio] [decimal](9, 5) NULL,
  [NombreCliente] [varchar](200) NULL,
  [DescripcionTran] [varchar](1000) NULL,
  [CodCajero] [varchar](15) NULL,
  [CodMoneda] [tinyint] NULL,
  [MontoCapitalTran] [money] NULL,
  [MontoInteresTran] [money] NULL,
  [MontoINVETran] [money] NULL,
  [MontoINPETran] [money] NULL,
  [MontoCargos] [money] NULL,
  [MontoOtrosTran] [money] NULL,
  [MontoImpuestos] [money] NULL,
  [MontoTotalTran] [money] NULL,
  [FechaApertura] [smalldatetime] NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [CodBanco] [varchar](30) NULL,
  [NroCuenta] [varchar](30) NULL,
  [NroCheque] [varchar](30) NULL,
  [NroSecuencial] [int] NULL,
  [CodMotivo] [int] NULL,
  [CodUsuario] [varchar](15) NOT NULL CONSTRAINT [DF_tCsTransaccionDiaria_CodUsuario] DEFAULT (''),
  [CodAsesor] [varchar](15) NULL,
  [CodProducto] [char](10) NULL,
  [CodDestino] [varchar](15) NULL,
  [CodTipoCredito] [tinyint] NULL,
  [MontoDescontado] [smallmoney] NULL,
  [Secuencia] [int] NULL,
  [TasaInteres] [decimal](19, 4) NULL,
  [Sistemas] [int] NULL,
  CONSTRAINT [PK_tCsTransaccionDiaria] PRIMARY KEY CLUSTERED ([Fecha], [CodigoCuenta], [FraccionCta], [Renovado], [CodSistema], [CodOficina], [NroTransaccion], [TipoTransacNivel1], [TipoTransacNivel2], [TipoTransacNivel3], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsTransaccionDiaria_CodigoCuenta_FraccionCta_Renovado_TipoTransacNivel1_TipoTransacNivel3_Extornado_Fecha]
  ON [dbo].[tCsTransaccionDiaria] ([CodigoCuenta], [FraccionCta], [Renovado], [TipoTransacNivel1], [TipoTransacNivel3], [Extornado], [Fecha])
  INCLUDE ([MontoTotalTran])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsTransaccionDiaria_CodSistema_Extornado_Fecha_TipoTransacNivel3_MontoTotalTran]
  ON [dbo].[tCsTransaccionDiaria] ([CodSistema], [Extornado], [Fecha], [TipoTransacNivel3], [MontoTotalTran])
  INCLUDE ([CodigoCuenta], [Renovado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsTransaccionDiaria_CodSistema_TipoTransacNivel3_Fecha_CodOficina]
  ON [dbo].[tCsTransaccionDiaria] ([CodSistema], [TipoTransacNivel3], [Fecha], [CodOficina])
  INCLUDE ([CodigoCuenta], [TipoTransacNivel2])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsTransaccionDiaria_Fecha_CodigoCuenta_Extornado_TipoTransacNivel1]
  ON [dbo].[tCsTransaccionDiaria] ([Fecha], [CodigoCuenta], [Extornado], [TipoTransacNivel1])
  INCLUDE ([MontoInteresTran])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsTransaccionDiaria] TO [int_mmartinezp]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de generacion del saldo', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del prestamo o cta de ahorro u otro', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodigoCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de fraccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'FraccionCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de renovaciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'Renovado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del sistema que genera la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodSistema'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'sujeto a discusion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TranHora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'sujeto a discusion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TranMinuto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'sujeto a discusion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TranSegundo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'microsegundo del inicio de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TranMicroSegundo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la Oficina donde se realizó la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la oficina de la ccuenta involucrada', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodOficinaCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'SecPago, ahorros????', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'NroTransaccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'I=Ingreso, E=Egreso', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TipoTransacNivel1'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1:EFEC 2:CHEQ 3:SIST 4:OTRO 5:INTER (CodServicio) 0:Desconocido', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TipoTransacNivel2'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'de 1 a 100 es de Ahorros, de 101 a 200 para cartera, 201 a 300 otros', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TipoTransacNivel3'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0:Normal, 1:Extornado', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'Extornado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'tipo de cambio de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TipoCambio'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'sujeto a discusion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'NombreCliente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripcion o glosa de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'DescripcionTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de cajero', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodCajero'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de la moneda de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto capital de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'MontoCapitalTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto interes de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'MontoInteresTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto INVE de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'MontoINVETran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto INPE de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'MontoINPETran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto de otros conceptos de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'MontoOtrosTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de la transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'MontoTotalTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ahorros', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'FechaApertura'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ahorros', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'FechaVencimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'operaciones con cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodBanco'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'operaciones con cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'NroCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'operaciones con cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'NroCheque'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'numero secuencia para transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'NroSecuencial'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del Motivo', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodMotivo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', NULL, 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'CodTipoCredito'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'tasa de interes anual', 'SCHEMA', N'dbo', 'TABLE', N'tCsTransaccionDiaria', 'COLUMN', N'TasaInteres'
GO