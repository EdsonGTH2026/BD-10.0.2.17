CREATE TABLE [dbo].[tPDSolicitud] (
  [IdSolicitud] [bigint] NOT NULL,
  [Fecha] [smalldatetime] NULL,
  [Hora] [datetime] NULL,
  [CodSistema] [char](2) NULL,
  [Version] [varchar](20) NULL,
  [ItemProceso] [int] NULL,
  [Descripcion] [text] NULL,
  [IpServidor] [varchar](10) NULL,
  [NombreBase] [varchar](50) NULL,
  [EstadoBase] [bit] NULL,
  [CodUsuarioReg] [varchar](15) NULL,
  [CodUsuarioDes] [varchar](15) NULL,
  [CodUsuarioApro] [varchar](15) NULL,
  [Estado] [int] NULL,
  [FecCamEstado] [smalldatetime] NULL,
  [FechaFin] [smalldatetime] NULL,
  [HoraFin] [datetime] NULL,
  CONSTRAINT [PK_tPDSolProduccion] PRIMARY KEY CLUSTERED ([IdSolicitud])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO