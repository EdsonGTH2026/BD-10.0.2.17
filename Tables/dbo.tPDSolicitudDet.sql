CREATE TABLE [dbo].[tPDSolicitudDet] (
  [IdSolicitud] [bigint] NOT NULL,
  [ItemSolDet] [int] NOT NULL,
  [RutaImagen] [varchar](200) NULL,
  [Descripcion] [text] NULL,
  CONSTRAINT [PK_tPDSolicitudDet] PRIMARY KEY CLUSTERED ([IdSolicitud], [ItemSolDet])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPDSolicitudDet]
  ADD CONSTRAINT [FK_tPDSolicitudDet_tPDSolicitud] FOREIGN KEY ([IdSolicitud]) REFERENCES [dbo].[tPDSolicitud] ([IdSolicitud])
GO