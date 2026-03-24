CREATE TABLE [dbo].[tUsUsuarios] (
  [CodUsuario] [char](15) NOT NULL,
  [CodTPersona] [varchar](2) NOT NULL,
  [CodEntidadTipo] [varchar](3) NULL,
  [Paterno] [varchar](30) NULL,
  [Materno] [varchar](30) NULL,
  [Nombres] [varchar](50) NULL,
  [ApeEsposo] [varchar](30) NULL,
  [NombreCompleto] [varchar](120) NULL,
  [CodDocIden] [varchar](5) NOT NULL,
  [DI] [varchar](20) NULL,
  [FechaNacimiento] [smalldatetime] NULL,
  [CodEstadoCivil] [char](1) NULL,
  [Sexo] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarios_Sexo] DEFAULT (1),
  [CodPais] [varchar](4) NULL,
  [CodUsConyuge] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  [FechaIngreso] [smalldatetime] NULL,
  [FechaReg] [datetime] NULL,
  [CodUsResp] [char](15) NULL,
  [CodAnterior] [varchar](15) NOT NULL CONSTRAINT [DF_tUsUsuarios_CodAnterior] DEFAULT (''),
  [CodVIP] [char](1) NOT NULL CONSTRAINT [DF_tUsUsuarios_CodVIP] DEFAULT ('0'),
  [IServidor] [datetime] NULL CONSTRAINT [DF_tUsUsuarios_IServidor] DEFAULT (getdate()),
  CONSTRAINT [PK_tUsUsuarios] PRIMARY KEY CLUSTERED ([CodUsuario])
)
ON [PRIMARY]
GO