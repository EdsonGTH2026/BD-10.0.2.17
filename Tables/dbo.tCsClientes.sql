CREATE TABLE [dbo].[tCsClientes] (
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOrigen] [varchar](15) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [CodTPersona] [varchar](2) NULL,
  [CodEntidadTipo] [varchar](3) NULL,
  [FechaIngreso] [datetime] NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [Nombres] [varchar](80) NULL,
  [ApeEsposo] [varchar](50) NULL,
  [NombreCompleto] [varchar](300) NULL,
  [CodDocIden] [varchar](5) NULL,
  [DI] [varchar](20) NULL,
  [usCURP] [varchar](20) NULL,
  [usRFC] [varchar](20) NULL,
  [FechaNacimiento] [smalldatetime] NULL,
  [CodEstadoCivil] [char](1) NULL,
  [Sexo] [bit] NULL CONSTRAINT [DF_tCsClientes_Sexo] DEFAULT (1),
  [CodPais] [varchar](4) NOT NULL,
  [CodUbiGeoDirFamPri] [varchar](6) NULL,
  [DireccionDirFamPri] [varchar](150) NULL,
  [NumExtFam] [varchar](10) NULL,
  [NumIntFam] [varchar](10) NULL,
  [TelefonoDirFamPri] [varchar](20) NULL,
  [CodPostalFam] [varchar](10) NULL,
  [CodUbiGeoDirNegPri] [varchar](6) NULL,
  [DireccionDirNegPri] [varchar](150) NULL,
  [NumExtNeg] [varchar](10) NULL,
  [NumIntNeg] [varchar](10) NULL,
  [TelefonoDirNegPri] [varchar](20) NULL,
  [CodPostalNeg] [varchar](10) NULL,
  [TelefonoMovil] [varchar](50) NULL,
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
  [IngresoMensual] [decimal](18, 4) NULL,
  [CodUsResp] [char](15) NULL,
  [ClienteDe] [varchar](50) NULL,
  [Activo] [bit] NULL CONSTRAINT [DF_tCsClientes_Activo] DEFAULT (0),
  [UsNVivenCon] [int] NULL,
  [UsNDependientes] [int] NULL,
  [UsNHijosMay] [int] NULL,
  [UsNHijosMen] [int] NULL,
  [TipoPropiedadDirFam] [varchar](10) NULL,
  [TipoPropiedadDirNeg] [varchar](10) NULL,
  [TiempoResidirDirFam] [int] NULL,
  [TiempoResidirDirNeg] [int] NULL,
  [SituacionLaboral] [varchar](50) NULL,
  [OtrosIngresos] [decimal](18, 4) NULL,
  [CodConyuge] [varchar](15) NULL,
  [EsNuevaGeneracionCodigo] [bit] NULL CONSTRAINT [DF_tCsClientes_EsNuevaGeneracionCodigo] DEFAULT (0),
  [UsRFCBD] [varchar](13) NULL,
  [UsCURPBD] [varchar](18) NULL,
  CONSTRAINT [PK_tCsClientes] PRIMARY KEY CLUSTERED ([CodOrigen])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_EsNuevaGeneracionCodigo_CodUsuario]
  ON [dbo].[tCsClientes] ([EsNuevaGeneracionCodigo], [CodUsuario], [CodOrigen], [CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_EsNuevaGeneracionCodigo_CodUsuario_CodOficina]
  ON [dbo].[tCsClientes] ([EsNuevaGeneracionCodigo], [CodUsuario], [CodOficina], [CodDocIden], [DI])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientes_2]
  ON [dbo].[tCsClientes] ([CodDocIden], [DI])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientes_3]
  ON [dbo].[tCsClientes] ([CodUsuario], [CodOficina])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo del Usuario', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de Oficina', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de tipo de persona 
(01 es natural).', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodTPersona'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de Ingreso a la BD.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'FechaIngreso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Apellido Paterno', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'Paterno'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Apellido Materno', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'Materno'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombres', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'Nombres'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Apellido del esposo de ser 
mujer, casada y requerirse', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'ApeEsposo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Nombre completo como se 
reporta', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'NombreCompleto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de documento de 
identidad', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodDocIden'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Documento de Identidad', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'DI'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El RUC o R.F.C. del 
usuario.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'usRFC'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de Nacimiento', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'FechaNacimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'C=Casado, D=Divorciado, 
S=Soltero, U=Union Libre, V=Viudo', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodEstadoCivil'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1=Masc, 0=Feme', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'Sexo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de pais de 
nacionalidad', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodPais'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Ubigeo de la 
dirección principal de domicilio del cliente.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodUbiGeoDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de dirección 
principal familiar del cliente.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'DireccionDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la dirección 
principal de la familia.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'TelefonoDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Ubigeo de la 
dirección principal de negocio del cliente.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodUbiGeoDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de dirección 
principaldel negocio del cliente.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'DireccionDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la dirección 
principal del negocio.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'TelefonoDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Profesion del usuario segun 
tabla ciuo.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'UsCodOcupacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo internacional de 
actividad', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'LabCodActividad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Si es residente del pais.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'UsEsResidente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Si es accionista de la 
empresa.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'UsEsAccionista'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Si es empleado nuestro o 
no.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'UsEsEmpleado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Relacion laboral con la 
empresa nuestra.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'UsRelacionLaboralNos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sigla de la empresa', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'JurSigla'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Usuario Responsable del 
cliente o empleado.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'CodUsResp'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'AH=Ahorros, CA=Cartera, 
GI=Giros', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'ClienteDe'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1=Activo, 0=Inactivo', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientes', 'COLUMN', N'Activo'
GO