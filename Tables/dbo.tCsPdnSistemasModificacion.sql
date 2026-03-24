CREATE TABLE [dbo].[tCsPdnSistemasModificacion] (
  [Registro] [datetime] NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [VerMayor] [smallint] NOT NULL,
  [VerMenor] [smallint] NOT NULL,
  [VerRevision] [smallint] NOT NULL,
  [CURPDesarrollo] [varchar](20) NULL,
  [SDesarrollo] [varchar](8000) NULL,
  [CURPProduccion] [varchar](20) NULL,
  [SProduccion] [varchar](8000) NULL,
  CONSTRAINT [PK_tCsPdnSistemasModificacion] PRIMARY KEY CLUSTERED ([Registro], [CodSistema], [VerMayor], [VerMenor], [VerRevision])
)
ON [PRIMARY]
GO