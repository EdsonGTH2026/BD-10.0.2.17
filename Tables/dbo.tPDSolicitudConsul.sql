CREATE TABLE [dbo].[tPDSolicitudConsul] (
  [IdSolicitud] [bigint] NOT NULL,
  [ItemSolCon] [int] NOT NULL,
  [Interrogante] [text] NULL,
  [Respuesta] [text] NULL,
  [RutaImagen] [varchar](200) NULL,
  CONSTRAINT [PK_tPDSolicitudConsul] PRIMARY KEY CLUSTERED ([IdSolicitud], [ItemSolCon])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPDSolicitudConsul]
  ADD CONSTRAINT [FK_tPDSolicitudConsul_tPDSolicitud] FOREIGN KEY ([IdSolicitud]) REFERENCES [dbo].[tPDSolicitud] ([IdSolicitud])
GO