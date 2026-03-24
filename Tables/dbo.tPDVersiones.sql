CREATE TABLE [dbo].[tPDVersiones] (
  [CodSistema] [char](2) NOT NULL,
  [Version] [varchar](20) NOT NULL,
  [Item] [int] NOT NULL,
  [VerPrincipal] [smallint] NULL,
  [VerSecundaria] [smallint] NULL,
  [VerCompilacion] [smallint] NULL,
  [Revision] [smallint] NULL,
  [FechaAlta] [smalldatetime] NULL,
  [HoraAlta] [datetime] NULL,
  [Codusuario] [varchar](15) NULL,
  [Usuario] [varchar](15) NULL,
  [Estado] [char](1) NULL,
  [RutaArchivo] [varchar](200) NULL,
  CONSTRAINT [PK_tPDVersiones] PRIMARY KEY CLUSTERED ([CodSistema], [Version], [Item])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPDVersiones] WITH NOCHECK
  ADD CONSTRAINT [FK_tPDVersiones_tPDSistemasObj] FOREIGN KEY ([CodSistema], [Item]) REFERENCES [dbo].[tPDSistemasObj] ([CodSistema], [Item])
GO