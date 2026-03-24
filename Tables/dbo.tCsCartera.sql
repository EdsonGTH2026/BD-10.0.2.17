CREATE TABLE [dbo].[tCsCartera] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL CONSTRAINT [DF_tCsCartera1_CodPrestamo] DEFAULT (''),
  [CodSolicitud] [varchar](15) NULL CONSTRAINT [DF_tCsCartera1_CodSolicitud] DEFAULT (''),
  [CodOficina] [varchar](4) NULL CONSTRAINT [DF_tCsCartera1_CodOficina] DEFAULT (''),
  [CodProducto] [smallint] NULL CONSTRAINT [DF_tCsCartera1_CodProducto] DEFAULT (''),
  [CodAsesor] [varchar](15) NULL CONSTRAINT [DF_tCsCartera1_CodAsesor] DEFAULT (''),
  [CodUsuario] [varchar](15) NULL,
  [CodGrupo] [varchar](15) NULL,
  [CodFondo] [tinyint] NULL CONSTRAINT [DF_tCsCartera1_CodFondo] DEFAULT (''),
  [CodTipoCredito] [tinyint] NULL CONSTRAINT [DF_tCsCartera1_CodTipoCredito] DEFAULT (0),
  [CodDestino] [char](10) NULL CONSTRAINT [DF_tCsCartera1_CodDestino] DEFAULT (''),
  [NivelAprobacion] [varchar](50) NULL CONSTRAINT [DF_tCsCartera1_NivelAprobacion] DEFAULT (''),
  [BIS] [int] NULL,
  [Estado] [varchar](50) NULL CONSTRAINT [DF_tCsCartera1_Estado] DEFAULT (''),
  [EstadoAnterior] [varchar](50) NULL,
  [FechaEstado] [smalldatetime] NULL,
  [FechaCastigo] [smalldatetime] NULL,
  [ProximoVencimiento] [smalldatetime] NULL,
  [TipoReprog] [char](5) NULL CONSTRAINT [DF_tCsCartera1_TipoReprog] DEFAULT (''),
  [NumReprog] [int] NULL,
  [FechaReprog] [smalldatetime] NULL,
  [PrestamoReprog] [varchar](25) NULL,
  [NroDiasCredito] [int] NULL CONSTRAINT [DF_tCsCartera1_NroDiasCredito] DEFAULT (0),
  [NroDiasAtraso] [int] NULL CONSTRAINT [DF_tCsCartera1_NroDiasAtraso] DEFAULT (0),
  [NroDiasAcumulado] [int] NULL,
  [NroDiasMin] [int] NULL,
  [NroDiasMax] [int] NULL,
  [ModalidadPlazo] [char](2) NULL CONSTRAINT [DF_tCsCartera1_ModalidadPlazo] DEFAULT ('CP'),
  [NroCuotas] [smallint] NULL CONSTRAINT [DF_tCsCartera1_NroCuotas] DEFAULT (0),
  [CuotaActual] [int] NULL,
  [NroCuotasPagadas] [smallint] NULL CONSTRAINT [DF_tCsCartera1_NroCuotasPagadas] DEFAULT (0),
  [NroCuotasPorPagar] [smallint] NULL CONSTRAINT [DF_tCsCartera1_NroCuotasPorPagar] DEFAULT (0),
  [NroDiasPagocuota1] [smallint] NULL CONSTRAINT [DF_tCsCartera1_NroDiasPagocuota1] DEFAULT (0),
  [NrodiasEntreCuotas] [smallint] NULL CONSTRAINT [DF_tCsCartera1_NrodiasEntreCuotas] DEFAULT (0),
  [SecuenciaSolicitud] [int] NULL,
  [FechaSolicitud] [smalldatetime] NULL,
  [FechaAprobacion] [smalldatetime] NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [MontoDesembolso] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_MontoDesembolso] DEFAULT (0),
  [CodMoneda] [smallint] NULL CONSTRAINT [DF_tCsCartera1_CodMoneda] DEFAULT (''),
  [TipoCambio] [decimal](18, 7) NULL CONSTRAINT [DF_tCsCartera1_TipoCambio] DEFAULT (0),
  [SaldoCapital] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoCapital] DEFAULT (0),
  [CapitalVigente] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoCapitalAtrasado] DEFAULT (0),
  [CapitalVencido] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoCapitalVencido] DEFAULT (0),
  [CapitalMonetizado] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoCapitalMonetizado] DEFAULT (0),
  [SaldoInteresCorriente] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoInteresCorriente] DEFAULT (0),
  [SaldoINVE] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoInteresCompensatorio] DEFAULT (0),
  [SaldoINPE] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoInteresMoratorio] DEFAULT (0),
  [SaldoEnMora] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoEnMora] DEFAULT (0),
  [CargoMora] [decimal](19, 4) NULL,
  [OtrosCargos] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoOtrosCargos] DEFAULT (0),
  [Impuestos] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_OtrosCargos1] DEFAULT (0),
  [CodRuta] [varchar](10) NULL CONSTRAINT [DF_tCsCartera1_CodRuta] DEFAULT (''),
  [Calificacion] [char](1) NULL CONSTRAINT [DF_tCsCartera1_Calificacion] DEFAULT (''),
  [ProvisionCapital] [decimal](19, 4) NULL,
  [ProvisionInteres] [decimal](19, 4) NULL,
  [GarantiaLiquidaMonetizada] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_GarantiaLiquidaMonetizada] DEFAULT (0),
  [GarantiaPreferidaMonetizada] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_GarantiaPreferidaMonetizada] DEFAULT (0),
  [GarantiaMuyRapidaRealizacion] [decimal](19, 4) NULL,
  [TotalGarantia] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_TotalGarantia] DEFAULT (0),
  [FechaUltimoMovimiento] [datetime] NULL,
  [TasaIntCorriente] [decimal](18, 7) NULL CONSTRAINT [DF_tCsCartera1_TasaIntCorriente] DEFAULT (0),
  [TasaINVE] [decimal](18, 7) NULL CONSTRAINT [DF_tCsCartera1_TasaIntCompensatorio] DEFAULT (0),
  [TasaINPE] [decimal](18, 7) NULL CONSTRAINT [DF_tCsCartera1_TasaIntMoratorio] DEFAULT (0),
  [CodAnterior] [varchar](27) NULL CONSTRAINT [DF_tCsCartera1_CodAnterior_1] DEFAULT (''),
  [TipoCalificacion] [char](1) NULL,
  [ComisionDesembolso] [decimal](19, 4) NULL,
  [SaldoINTEVig] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoINTEVig] DEFAULT (0),
  [SaldoINPEVig] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoINPEVig] DEFAULT (0),
  [SaldoINTESus] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoINTESus] DEFAULT (0),
  [SaldoINPESus] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera1_SaldoINPESus] DEFAULT (0),
  [Condonado] [bit] NULL,
  [Cartera] [varchar](50) NULL,
  [EstadoFinmas] [varchar](50) NULL,
  [Judicial] [varchar](50) NULL,
  [Sectorista2] [varchar](15) NULL,
  [Carta] [varchar](50) NULL,
  [CEmision] [datetime] NULL,
  [Cobranza] [varchar](3) NULL,
  CONSTRAINT [PK_tCsCartera] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

CREATE INDEX [IX_Estado_Fecha_CodOficina_NroDiasAtraso]
  ON [dbo].[tCsCartera] ([Estado], [Fecha], [CodOficina], [NroDiasAtraso], [CodPrestamo], [CodFondo])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera]
  ON [dbo].[tCsCartera] ([Fecha], [CodPrestamo], [CodOficina], [Cartera], [Estado], [NroDiasAtraso])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_11]
  ON [dbo].[tCsCartera] ([Fecha], [NroDiasAtraso])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_12]
  ON [dbo].[tCsCartera] ([Fecha], [CuotaActual])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_5]
  ON [dbo].[tCsCartera] ([CodProducto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_8]
  ON [dbo].[tCsCartera] ([Estado])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_CodPrestamo]
  ON [dbo].[tCsCartera] ([CodPrestamo])
  INCLUDE ([NroDiasAtraso])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_Fecha_Cartera_CodOficina]
  ON [dbo].[tCsCartera] ([Fecha], [Cartera], [CodOficina])
  INCLUDE ([CodPrestamo], [CodAsesor], [Estado], [NroDiasAtraso])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_Fecha_CodOficina]
  ON [dbo].[tCsCartera] ([Fecha], [CodOficina])
  INCLUDE ([CodPrestamo], [CodAsesor], [SaldoCapital])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_Fecha_CodOficina_Cartera]
  ON [dbo].[tCsCartera] ([Fecha], [CodOficina], [Cartera])
  INCLUDE ([CodPrestamo], [CodAsesor], [NroDiasAtraso], [SaldoCapital])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera_Fecha_CodOficina_Cartera_NroDiasAtraso]
  ON [dbo].[tCsCartera] ([Fecha], [CodOficina], [Cartera], [NroDiasAtraso])
  INCLUDE ([CodPrestamo])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [ope_dalvarador]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsCartera] TO [int_mmartinezp]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de generacion del saldo', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo Finmas del credito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de solicitud', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodSolicitud'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de la oficina donde se genero el credito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del producto de credito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del asesor principal', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del cliente, Null si es Grupal', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de grupo, Null si es individual', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodGrupo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del fondo al cual pertenece el prestamo', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodFondo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de tipo de credito (1=Comercial; 2=Microcredito; 3=Consumo; 4=Hipotecario)', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodTipoCredito'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del destino que le da el cliente a lcredito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodDestino'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del credito segun la parametrizacion del cliente', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica la modalidad del crédito, Corto Plazo (CP) es <= un año, largo plazo (LP) > un año', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'ModalidadPlazo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de desembolso pactado ', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'MontoDesembolso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de moneda del prestamo', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo capital de las cuotas con DiasAtraso > 0', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CapitalVigente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo capital de las cuotas con DiasAtraso > x, donde x esta parametrizado segun estado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CapitalVencido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de capital a la fecha monetizado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CapitalMonetizado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de ruta ozona asignada al sectorista', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodRuta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Calificacion segun parametrizacion', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'Calificacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de garantia liquida del prestamo (monetizado)', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'GarantiaLiquidaMonetizada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de garantia preferida del prestamo (monetizado)', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'GarantiaPreferidaMonetizada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de último movimiento. Todo aquello que NO es resultado de un proceso automático como el proceso de cierre. Ejemplo una transacción manual hecha por cajero', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'FechaUltimoMovimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Prestamo en el sistema Anterior', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'CodAnterior'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera', 'COLUMN', N'ComisionDesembolso'
GO