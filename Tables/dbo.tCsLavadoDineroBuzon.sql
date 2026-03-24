CREATE TABLE [dbo].[tCsLavadoDineroBuzon] (
  [IdBuzon] [int] IDENTITY,
  [CodEmpleadoDenuncia] [varchar](15) NOT NULL,
  [NomEmpleadoDenuncia] [varchar](60) NOT NULL,
  [FechaReporte] [datetime] NOT NULL,
  [CodOficinaReporte] [varchar](3) NOT NULL,
  [CodEmpleadoReporte] [varchar](15) NOT NULL,
  [NomEmpleadoReporte] [varchar](60) NOT NULL,
  [MotivosReporte] [varchar](250) NOT NULL,
  [CodUsuarioCreacion] [varchar](15) NOT NULL,
  [FechaCreacion] [datetime] NOT NULL,
  [GestionCodUsuario] [varchar](15) NULL,
  [GestionProcedeInvestigacion] [varchar](2) NULL,
  [GestionComentarios] [varchar](500) NULL,
  [GestionEstatus] [varchar](10) NULL,
  [GestionFecha] [datetime] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsLavadoDineroBuzon] PRIMARY KEY CLUSTERED ([IdBuzon])
)
ON [PRIMARY]
GO