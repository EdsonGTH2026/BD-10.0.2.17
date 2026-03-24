CREATE TABLE [dbo].[tCsAhorros] (
  [Fecha] [datetime] NOT NULL,
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL CONSTRAINT [DF_tCsAhorros_FraccionCta] DEFAULT (''),
  [Renovado] [tinyint] NOT NULL CONSTRAINT [DF_tCsAhorros_Renovado] DEFAULT (0),
  [CodOficina] [varchar](4) NULL,
  [CodProducto] [varchar](3) NULL,
  [CodMoneda] [tinyint] NULL,
  [CodUsuario] [varchar](15) NULL CONSTRAINT [DF_tCsAhorros_CodUsuario] DEFAULT (''),
  [FormaManejo] [smallint] NULL,
  [FechaApertura] [datetime] NULL,
  [FechaVencimiento] [datetime] NULL,
  [FechaCierre] [datetime] NULL,
  [TasaInteres] [money] NULL,
  [FechaUltMov] [datetime] NULL,
  [TipoCambioFijo] [decimal](18, 7) NULL CONSTRAINT [DF_tCsAhorros_TipoCambioFijo] DEFAULT (1),
  [SaldoCuenta] [money] NULL,
  [SaldoMonetizado] [money] NULL,
  [MontoInteres] [money] NULL,
  [IntAcumulado] [money] NULL CONSTRAINT [DF_tCsAhorros_IntAcumulado] DEFAULT (0),
  [MontoInteresCapitalizado] [money] NULL,
  [MontoBloqueado] [money] NULL,
  [MontoRetenido] [money] NULL,
  [InteresCalculado] [money] NULL CONSTRAINT [DF_tCsAhorros_InteresCalculado] DEFAULT (0),
  [Plazo] [numeric](10) NULL,
  [Lucro] [bit] NULL,
  [CodAsesor] [varchar](15) NULL,
  [CodOficinaUltTransaccion] [varchar](4) NULL,
  [TipoUltTransaccion] [smallint] NULL,
  [FechaUltCapitalizacion] [datetime] NULL,
  [IdDocRespaldo] [int] NULL,
  [NroSerie] [varchar](25) NULL,
  [idEstadoCta] [char](2) NULL,
  [NomCuenta] [varchar](80) NULL,
  [FondoConfirmar] [money] NULL CONSTRAINT [DF_tCsAhorros_FondoConfirmar] DEFAULT (0),
  [Observacion] [varchar](500) NULL,
  [EnGarantia] [bit] NULL CONSTRAINT [DF_tCsAhorros_EnGarantia] DEFAULT (0),
  [Garantia] [varchar](50) NULL,
  [CuentaPreferencial] [bit] NULL CONSTRAINT [DF_tCsAhorros_CuentaPreferencial] DEFAULT (0),
  [CuentaReservada] [bit] NULL CONSTRAINT [DF_tCsAhorros_CuentaReservada] DEFAULT (0),
  [CodCuentaAnt] [varchar](25) NULL,
  [AplicaITF] [bit] NULL,
  [PorcCliente] [int] NULL,
  [PorcInst] [int] NULL,
  [idTipoCapi] [smallint] NULL,
  [FechaCambioEstado] [datetime] NULL,
  [FechaInactivacion] [datetime] NULL,
  [NroSolicitud] [varchar](25) NULL,
  [CodTipoInteres] [smallint] NULL,
  [IdTipoRenova] [smallint] NULL,
  [PlazoDiasRenov] [int] NULL,
  [InteresCapitalizable] [bit] NULL,
  [CodPrestamo] [varchar](25) NULL,
  [MontoGarantia] [money] NULL,
  [TipoConta] [varchar](10) NULL,
  [ContaCodigo] [varchar](25) NULL,
  CONSTRAINT [PK_tCsAhorros] PRIMARY KEY CLUSTERED ([Fecha], [CodCuenta], [FraccionCta], [Renovado])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsAhorros_2]
  ON [dbo].[tCsAhorros] ([CodCuenta], [FraccionCta], [Renovado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsAhorros_3]
  ON [dbo].[tCsAhorros] ([Fecha], [CodProducto], [CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsAhorros_Fecha_FechaVencimiento_idEstadoCta]
  ON [dbo].[tCsAhorros] ([Fecha], [FechaVencimiento], [idEstadoCta])
  INCLUDE ([CodCuenta], [FraccionCta], [Renovado], [CodOficina], [CodProducto], [CodMoneda], [CodUsuario], [FormaManejo], [FechaApertura], [TasaInteres], [SaldoCuenta], [MontoInteres], [IntAcumulado], [MontoBloqueado], [Plazo], [CodTipoInteres])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [rie_sbravoa]
GO

DENY SELECT ON [dbo].[tCsAhorros] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [ope_dalvarador]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsAhorros] TO [Int_dreyesg]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de generacion del saldo', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de fraccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FraccionCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de renovaciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'Renovado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la Oficina de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del producto', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de moneda de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del titular de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FormaManejo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de apertura de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaApertura'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de vencimiento de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaVencimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de cierre de cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaCierre'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'tasa de interes anual', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'TasaInteres'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de ultimo movimiento', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaUltMov'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de cambio', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'TipoCambioFijo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'SaldoCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo monetizado al tipo de cambio del dia', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'SaldoMonetizado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Devengado (ctas ah), por pagar (DPF)', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'MontoInteres'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Interes acumulado o devengado.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'IntAcumulado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de interes capitalizado', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'MontoInteresCapitalizado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto bloqueado', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'MontoBloqueado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto retenido', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'MontoRetenido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Interes Calculado por dia', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'InteresCalculado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'solo para DPFs', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'Plazo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1=Con fines de lucro, 0= Sin ffines de lucro', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'Lucro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del asesor o sectorista', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la oficina de la ultima transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodOficinaUltTransaccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de la ultima transaccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'TipoUltTransaccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de la ultima capitalizacion', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaUltCapitalizacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Documento de Respaldo', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'IdDocRespaldo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nro de Serie de el Doc de Respaldo', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'NroSerie'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Clave del estado de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'idEstadoCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'NomCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fondos por confirmar.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FondoConfirmar'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Observaciones de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'Observacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si la cuenta esta en garantia o pignorada.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'EnGarantia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si es una cuenta preferencial o no.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CuentaPreferencial'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si es una cuenta reservada o no.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CuentaReservada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'código de Cuenta del SIF', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodCuentaAnt'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si la cuenta aplica ITF o no', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'AplicaITF'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Porcentaje de ITF q paga el cliente', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'PorcCliente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Porcentaje de ITF q paga la Institucion', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'PorcInst'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Clave del tipo de capitalización.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'idTipoCapi'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de cambio de estado.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaCambioEstado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de inactivación de la cuenta.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'FechaInactivacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de solicitud de la cuenta.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'NroSolicitud'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Clave del tipo de interes de la cuenta.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodTipoInteres'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Clave primaria del tipo de renovación', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'IdTipoRenova'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica los días para la renovación automática.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'PlazoDiasRenov'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si el interés generado se capitaliza al momento de la renovación.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'InteresCapitalizable'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Registra el número de prestamo que garantiza.', 'SCHEMA', N'dbo', 'TABLE', N'tCsAhorros', 'COLUMN', N'CodPrestamo'
GO