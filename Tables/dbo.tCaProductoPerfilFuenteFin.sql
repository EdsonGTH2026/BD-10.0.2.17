CREATE TABLE [dbo].[tCaProductoPerfilFuenteFin] (
  [CodProducto] [char](3) NOT NULL,
  [CodFondo] [varchar](2) NOT NULL,
  CONSTRAINT [PK_tCaProductoPerfilFuenteFin] PRIMARY KEY CLUSTERED ([CodProducto], [CodFondo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProductoPerfilFuenteFin] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProductoPerfilFuenteFin_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO

ALTER TABLE [dbo].[tCaProductoPerfilFuenteFin] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProductoPerfilFuenteFin_tClFondos] FOREIGN KEY ([CodFondo]) REFERENCES [dbo].[tClFondos] ([CodFondo])
GO