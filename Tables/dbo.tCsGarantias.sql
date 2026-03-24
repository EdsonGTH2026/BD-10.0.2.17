CREATE TABLE [dbo].[tCsGarantias] (
  [Codigo] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [TipoGarantia] [varchar](5) NOT NULL,
  [DocPropiedad] [varchar](25) NOT NULL,
  [NoAvaluo] [varchar](25) NULL CONSTRAINT [DF_tCsGarantias_NoAvaluo] DEFAULT (''),
  [CodSolicitud] [varchar](15) NULL,
  [Correlativo] [tinyint] NULL CONSTRAINT [DF_tCsGarantias_Correlativo] DEFAULT (0),
  [Identificador] [varchar](15) NULL CONSTRAINT [DF_tCsGarantias_Identificador] DEFAULT (''),
  [FechRegistro] [datetime] NULL,
  [FechUltAvaluo] [datetime] NULL,
  [MoComercial] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoComercial] DEFAULT (0),
  [MoAfectacion] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoAfectacion] DEFAULT (0),
  [MoFluctu] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoFluctu] DEFAULT (0),
  [MoDepre] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoDepre] DEFAULT (0),
  [MoNeto] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoNeto] DEFAULT (0),
  [MoAFavor] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoAFavor] DEFAULT (0),
  [MoOtros] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoOtros] DEFAULT (0),
  [MoAnterior] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoAnterior] DEFAULT (0),
  [MoHipotecario] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoHipotecario] DEFAULT (0),
  [MoLiqui] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoLiqui] DEFAULT (0),
  [MoImposi] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoImposi] DEFAULT (0),
  [PeMonPatrimonio] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_PeMonPatrimonio] DEFAULT (0),
  [MoCapacidad] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_MoCapacidad] DEFAULT (0),
  [CodMoneda] [varchar](2) NULL CONSTRAINT [DF_tCsGarantias_CodMoneda] DEFAULT (''),
  [CodSistema] [char](2) NULL CONSTRAINT [DF_tCsGarantias_CodSistema] DEFAULT (0),
  [TipoCambio] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_TipoCambio] DEFAULT (0),
  [PIInscripcion] [varchar](16) NULL CONSTRAINT [DF_tCsGarantias_PIInscripcion] DEFAULT (''),
  [PIFecha] [datetime] NULL,
  [Direccion] [varchar](50) NULL CONSTRAINT [DF_tCsGarantias_Direccion] DEFAULT (''),
  [Ubicacion] [varchar](80) NULL CONSTRAINT [DF_tCsGarantias_Ubicacion] DEFAULT (''),
  [CodLocalidad] [varchar](6) NULL CONSTRAINT [DF_tCsGarantias_CodLocalidad] DEFAULT (''),
  [DPFEntidad] [bit] NULL CONSTRAINT [DF_tCsGarantias_DPFEntidad] DEFAULT (0),
  [DPFCodTipoEnt] [varchar](3) NULL,
  [DPFCodEntidad] [varchar](3) NULL,
  [DPFCodCuenta] [varchar](50) NULL,
  [DPFFraccionCta] [varchar](8) NULL,
  [DPFRenovacion] [tinyint] NULL,
  [DPFFechAper] [datetime] NULL,
  [DPFFechVen] [datetime] NULL,
  [CDNroDoc] [varchar](50) NULL,
  [CDTipoDoc] [smallint] NULL,
  [CodEntiAseg] [varchar](3) NULL,
  [CodPoliza] [varchar](30) NULL CONSTRAINT [DF_tCsGarantias_CodPoliza] DEFAULT (''),
  [FechSeguro] [datetime] NULL,
  [FechVencPoli] [datetime] NULL,
  [TipoSeguro] [smallint] NULL,
  [Cobertura] [decimal](19, 4) NULL CONSTRAINT [DF_tCsGarantias_Cobertura] DEFAULT (0),
  [FechSalida] [datetime] NULL,
  [Obs] [varchar](200) NULL CONSTRAINT [DF_tCsGarantias_Obs] DEFAULT (''),
  [EstGarantia] [varchar](10) NULL CONSTRAINT [DF_tCsGarantias_EstGarantia] DEFAULT (''),
  [EstadoGar] [tinyint] NULL,
  [EsReal] [bit] NULL CONSTRAINT [DF_tCsGarantias_EsReal] DEFAULT (0),
  [Activo] [bit] NULL CONSTRAINT [DF_tCsGarantias_Activo] DEFAULT (0),
  [Caracteristica] [varchar](500) NULL,
  [CodEntiTipoAseg] [varchar](3) NULL,
  [DocPropiedadAnt] [varchar](25) NULL,
  CONSTRAINT [PK_tCsGarantias] PRIMARY KEY CLUSTERED ([Codigo], [CodOficina], [TipoGarantia], [DocPropiedad])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsGarantias] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsGarantias] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsGarantias] TO [rie_jalvarezc]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tabla de Garantias', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del prestamo, solicitud de crédito. boleta de garantía o línea de crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Codigo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de oficina de registro de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'TipoGarantia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del avalúo o valor único de la garantía especifica', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DocPropiedad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Numero de avaluo relacionado a la garantia', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'NoAvaluo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la solicitud de un crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodSolicitud'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número correlativo de las garantías activas', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Correlativo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de identificador de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Identificador'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de registro de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'FechRegistro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha del ultimo avaluo de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'FechUltAvaluo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto comercial de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoComercial'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de afectación de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoAfectacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de fluctuación de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoFluctu'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de depresiación de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoDepre'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto neto de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoNeto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto a favor del prestamo, boleta o línea de crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoAFavor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Otro monto de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoOtros'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto anterior de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoAnterior'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto hipotecario de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoHipotecario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de liquidación de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoLiqui'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto impositivo de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoImposi'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto del patrimonio personal', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'PeMonPatrimonio'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de capacidad de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'MoCapacidad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la moneda de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del sistema en que se registro la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodSistema'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'TipoCambio a la fecha de registro de la garantia', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'TipoCambio'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de Inscripción de inmueble', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'PIInscripcion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de inscripción de inmueble', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'PIFecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Dirección del inmueble', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Direccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Ubicación del inmueble', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Ubicacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la localidad del inmueble', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodLocalidad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Es un DPF de la Entidad', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFEntidad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del tipo de entidad del DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFCodTipoEnt'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la entidad del DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFCodEntidad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la cuenta DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFCodCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fracción de la cuenta DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFFraccionCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo renovado de la cuenta DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFRenovacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de apertura de la cuenta DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFFechAper'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de vencimiento de la cuenta DPF', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DPFFechVen'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número del documento en custodia', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CDNroDoc'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo del documento en custodia', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CDTipoDoc'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la entidad aseguradora', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodEntiAseg'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la poliza de seguro', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodPoliza'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de seguro', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'FechSeguro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de vencimiento del seguro', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'FechVencPoli'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de seguro', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'TipoSeguro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Porcentaje de cobertura del seguro', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Cobertura'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de liberación de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'FechSalida'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Observaciones de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Obs'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estados: ACTIVO, INACTIVO, MODIFICADO', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'EstGarantia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'2:Nuevo, 3:Modificado, 0:Inactivo', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'EstadoGar'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1:Garantía es real, 0:No real', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'EsReal'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1:garantía esta activa, 0:No', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Activo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Características de la garantía', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'Caracteristica'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del tipo de la entidad aseguradora', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'CodEntiTipoAseg'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código del documento de propiedad de la garantía anterior', 'SCHEMA', N'dbo', 'TABLE', N'tCsGarantias', 'COLUMN', N'DocPropiedadAnt'
GO