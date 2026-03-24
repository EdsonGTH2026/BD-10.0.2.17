CREATE TABLE [dbo].[tPDSistemasObj] (
  [CodSistema] [char](2) NOT NULL,
  [Item] [int] NOT NULL,
  [TipoObj] [smallint] NULL,
  [Nombre] [varchar](20) NULL,
  CONSTRAINT [PK_tPDSistemasObj] PRIMARY KEY CLUSTERED ([CodSistema], [Item])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPDSistemasObj]
  ADD CONSTRAINT [FK_tPDSistemasObj_tSgSistemas] FOREIGN KEY ([CodSistema]) REFERENCES [dbo].[tSgSistemas] ([CodSistema])
GO