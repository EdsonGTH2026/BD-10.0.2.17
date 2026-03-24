CREATE TABLE [dbo].[tCsLavadoDineroListaNegra] (
  [IdListaNegra] [int] IDENTITY,
  [FolioOficio] [varchar](25) NOT NULL,
  [TipoPersona] [varchar](1) NOT NULL,
  [Nombre1] [varchar](100) NOT NULL,
  [Nombre2] [varchar](20) NOT NULL,
  [ApellidoPaterno] [varchar](30) NOT NULL,
  [ApellidoMaterno] [varchar](30) NOT NULL,
  [RFC] [varchar](25) NOT NULL,
  [CURP] [varchar](25) NOT NULL,
  [FechaNacimiento] [datetime] NULL,
  [Domicilio] [varchar](80) NOT NULL,
  [DatosComplementarios] [varchar](100) NOT NULL,
  [CodUsuarioCreacion] [varchar](15) NOT NULL,
  [FechaCreacion] [datetime] NOT NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsLavadoDineroListaNegra] PRIMARY KEY CLUSTERED ([IdListaNegra])
)
ON [PRIMARY]
GO