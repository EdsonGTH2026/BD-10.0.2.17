CREATE TABLE [dbo].[tUsClEstadoCivil] (
  [CodEstadoCivil] [char](1) NOT NULL,
  [EstadoCivil] [varchar](15) NULL,
  [ConConyuge] [bit] NOT NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [tinyint] NULL,
  [NombreCasada] [char](3) NULL,
  [SHF] [int] NULL,
  [INTF] [char](1) NULL,
  [Masculino] [varchar](50) NULL,
  [Femenino] [varchar](50) NULL,
  CONSTRAINT [PK_tUsClEstadoCivil] PRIMARY KEY CLUSTERED ([CodEstadoCivil])
)
ON [PRIMARY]
GO