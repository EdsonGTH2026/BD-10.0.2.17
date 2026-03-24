CREATE TABLE [dbo].[tCsPLD_OperacionesInusuales] (
  [IdOperacion] [int] IDENTITY,
  [FechaIni] [datetime] NOT NULL,
  [FechaFin] [datetime] NOT NULL,
  [TipoPersona] [varchar](1) NOT NULL,
  [MontoLimite] [money] NOT NULL,
  [OperacionesLimite] [int] NOT NULL,
  [CodCliente] [varchar](15) NOT NULL,
  [MontoTotalPeriodo] [money] NOT NULL,
  [OperacionesPeriodo] [int] NOT NULL,
  [ClasificacionSistema] [int] NULL,
  [ClasificacionManual] [int] NULL,
  [Motivos] [varchar](100) NULL,
  [Dictamen] [varchar](1000) NULL,
  [FechaCreacion] [datetime] NOT NULL,
  [CodUsuarioCreacion] [varchar](15) NOT NULL,
  [Activo] [bit] NOT NULL,
  CONSTRAINT [PK_tCsPLD_OperacionesInusuales] PRIMARY KEY CLUSTERED ([IdOperacion])
)
ON [PRIMARY]
GO