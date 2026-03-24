CREATE TABLE [dbo].[tSgAdmAutorizaciones] (
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NOT NULL,
  [CodOficina] [varchar](5) NOT NULL,
  [CodUsuarioSol] [varchar](15) NOT NULL,
  [CodOficinaDes] [varchar](5) NULL,
  [CodUsuarioDes] [varchar](15) NULL,
  [PerfilSol] [varchar](100) NULL,
  [PerfilDes] [varchar](100) NULL,
  [PerfilEjecutado] [varchar](100) NULL,
  [FechaIni] [smalldatetime] NULL,
  [FechaFin] [smalldatetime] NULL,
  [Motivo] [text] NULL,
  [Estado] [char](1) NULL CONSTRAINT [DF_tSgAdmAutorizaciones_Estado] DEFAULT (1),
  [Usuario] [varchar](15) NULL,
  [UsuarioFirma] [varchar](15) NULL,
  CONSTRAINT [PK_tSgAdmAutorizaciones] PRIMARY KEY CLUSTERED ([Fecha], [Hora], [CodOficina], [CodUsuarioSol])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO