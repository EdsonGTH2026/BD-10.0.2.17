CREATE TABLE [dbo].[tCaSolicitudPropuesta] (
  [CodSolicitud] [varchar](15) NOT NULL,
  [CodProducto] [char](3) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodTipoPlan] [tinyint] NOT NULL,
  [CodTipoPlaz] [char](1) NOT NULL,
  [Plazo] [int] NULL,
  [Cuotas] [int] NOT NULL,
  CONSTRAINT [PK_tCaSolicitudPropuesta] PRIMARY KEY CLUSTERED ([CodSolicitud], [CodProducto], [CodOficina])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaSolicitudPropuesta] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitudPropuesta_tCaSolicitud] FOREIGN KEY ([CodSolicitud], [CodProducto], [CodOficina]) REFERENCES [dbo].[tCaSolicitud] ([CodSolicitud], [CodProducto], [CodOficina])
GO