CREATE TABLE [dbo].[tPDSistemasProc] (
  [CodSistema] [char](2) NOT NULL,
  [ItemProceso] [int] NOT NULL,
  [Nombre] [varchar](20) NULL,
  [Descripcion] [text] NULL,
  CONSTRAINT [PK_tPDSistemasProc] PRIMARY KEY CLUSTERED ([CodSistema], [ItemProceso])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPDSistemasProc]
  ADD CONSTRAINT [FK_tPDSistemasProc_tSgSistemas] FOREIGN KEY ([CodSistema]) REFERENCES [dbo].[tSgSistemas] ([CodSistema])
GO