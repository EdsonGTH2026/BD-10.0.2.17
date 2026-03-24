CREATE TABLE [dbo].[tCsConsolidaClientes] (
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOrigen] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  [CodTPersona] [varchar](2) NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [Nombres] [varchar](80) NULL,
  [NombreCompleto] [varchar](300) NULL,
  [usCURP] [varchar](20) NULL,
  [UsRFC] [varchar](20) NULL,
  [UsCURPBD] [varchar](18) NULL,
  [UsRFCBD] [varchar](20) NULL,
  [FechaNacimiento] [smalldatetime] NULL,
  [Sexo] [bit] NULL,
  [TelefonoMovil] [varchar](50) NULL,
  [LabCodActividad] [varchar](10) NULL,
  [FechaIngreso] [datetime] NULL,
  [FecRelacionComercial] [smalldatetime] NULL,
  [ReferenciaAH] [varchar](25) NULL,
  [ReferenciaCA] [varchar](25) NULL,
  [FechaReferenciaAH] [smalldatetime] NULL,
  [FechaReferenciaCA] [smalldatetime] NULL,
  [Tipo] [int] NOT NULL,
  [DescripcionTipo] [varchar](22) NOT NULL,
  [FechaCorte] [smalldatetime] NULL
)
ON [PRIMARY]
GO