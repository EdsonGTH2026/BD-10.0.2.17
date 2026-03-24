CREATE TABLE [dbo].[tCsPadronClientes] (
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOriginal] [varchar](15) NULL,
  [CodOrigen] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  [CodTPersona] [varchar](2) NULL,
  [CodEntidadTipo] [varchar](3) NULL,
  [FechaIngreso] [datetime] NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [Nombres] [varchar](80) NULL,
  [Nombre1] [varchar](50) NULL,
  [Nombre2] [varchar](50) NULL,
  [Nombre3] [varchar](50) NULL,
  [ApeEsposo] [varchar](50) NULL,
  [NombreCompleto] [varchar](300) NULL,
  [CodDocIden] [varchar](5) NOT NULL,
  [DI] [varchar](20) NOT NULL,
  [usCURP] [varchar](20) NULL,
  [UsRFC] [varchar](20) NULL,
  [UsRFCBD] [varchar](20) NULL,
  [UsRFCVal] AS (case when (rtrim(ltrim([usrfc])) = ltrim(rtrim([usrfcbd]))) then 1 else 0 end),
  [FechaNacimiento] [smalldatetime] NULL,
  [CodEstadoCivil] [char](1) NULL,
  [CodConyuge] [varchar](15) NULL,
  [Sexo] [bit] NULL CONSTRAINT [DF_tCsPadronClientes_Sexo1] DEFAULT (1),
  [CodPais] [varchar](4) NULL,
  [CodUbiGeoDirFamPri] [varchar](6) NULL,
  [TipoPropiedadDirFam] [varchar](10) NULL,
  [DireccionDirFamPri] [varchar](150) NULL,
  [NumExtFam] [varchar](10) NULL,
  [NumIntFam] [varchar](10) NULL,
  [TelefonoDirFamPri] [varchar](20) NULL,
  [CodPostalFam] [varchar](10) NULL,
  [TiempoResidirDirFam] [int] NULL,
  [CodUbiGeoDirNegPri] [varchar](6) NULL,
  [TipoPropiedadDirNeg] [varchar](10) NULL,
  [DireccionDirNegPri] [varchar](150) NULL,
  [NumExtNeg] [varchar](10) NULL,
  [NumIntNeg] [varchar](10) NULL,
  [TelefonoDirNegPri] [varchar](20) NULL,
  [CodPostalNeg] [varchar](10) NULL,
  [TiempoResidirDirNeg] [int] NULL,
  [TelefonoMovil] [varchar](50) NULL,
  [UsNVivenCon] [int] NULL,
  [UsNDependientes] [int] NULL,
  [UsNHijosMay] [int] NULL,
  [UsNHijosMen] [int] NULL,
  [UsCodOcupacion] [varchar](6) NULL,
  [LabCodActividad] [varchar](10) NULL,
  [UsEsResidente] [bit] NULL,
  [UsEsAccionista] [bit] NULL,
  [UsEsEmpleado] [bit] NULL,
  [UsRelacionLaboralNos] [char](1) NULL,
  [JurSigla] [varchar](25) NULL,
  [JurIdTipoJuridica] [smallint] NULL,
  [RubroNegocio] [varchar](100) NULL,
  [Actividad] [varchar](50) NULL,
  [GradoInstruccion] [varchar](50) NULL,
  [SituacionLaboral] [varchar](50) NULL,
  [IngresoMensual] [decimal](19, 4) NULL,
  [OtrosIngresos] [decimal](18, 4) NULL,
  [CodUsResp] [char](15) NULL,
  [ClienteDe] [varchar](50) NULL,
  [Activo] [bit] NULL CONSTRAINT [DF_tCsPadronClientes_Activo1] DEFAULT (0),
  [IDA] [varchar](3) NULL,
  [Prioridad] [int] NULL,
  [LocPatmir] [char](15) NULL,
  [UsCURPBD] [varchar](18) NULL,
  [FechaCorte] [smalldatetime] NULL,
  CONSTRAINT [PK_tCsPadronClientes_1] PRIMARY KEY CLUSTERED ([CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_CodDocIden_DI_usCURP]
  ON [dbo].[tCsPadronClientes] ([CodDocIden], [DI], [usCURP])
  ON [PRIMARY]
GO

CREATE INDEX [IX_CodDocIden_DI_UsRFC]
  ON [dbo].[tCsPadronClientes] ([CodDocIden], [DI], [UsRFC])
  ON [PRIMARY]
GO

CREATE INDEX [IX_CodTPersona_Nombres]
  ON [dbo].[tCsPadronClientes] ([CodTPersona], [Nombres])
  ON [PRIMARY]
GO

CREATE INDEX [IX_CodUbiGeoDirNegPri]
  ON [dbo].[tCsPadronClientes] ([CodUbiGeoDirNegPri])
  ON [PRIMARY]
GO

CREATE INDEX [IX_GradoInstruccion]
  ON [dbo].[tCsPadronClientes] ([GradoInstruccion])
  ON [PRIMARY]
GO

CREATE INDEX [IX_nombre2_nombre3]
  ON [dbo].[tCsPadronClientes] ([Nombre2], [Nombre3])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientes_1]
  ON [dbo].[tCsPadronClientes] ([CodOriginal])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientes_3]
  ON [dbo].[tCsPadronClientes] ([CodUsuario], [CodUbiGeoDirFamPri])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientes_4]
  ON [dbo].[tCsPadronClientes] ([CodUsuario], [CodUbiGeoDirNegPri])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientes_5]
  ON [dbo].[tCsPadronClientes] ([CodTPersona])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientes_CodOrigenCodUsuario]
  ON [dbo].[tCsPadronClientes] ([CodOrigen], [CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientes_CodOrigenLocPatmir]
  ON [dbo].[tCsPadronClientes] ([CodOrigen], [LocPatmir])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCLientes_CodUbiGeoDirFamPriCodUbiGeoDirNegPriCodOficina]
  ON [dbo].[tCsPadronClientes] ([CodUbiGeoDirFamPri], [CodUbiGeoDirNegPri], [CodOficina])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsPadronClientes] TO [int_mmartinezp]
GO