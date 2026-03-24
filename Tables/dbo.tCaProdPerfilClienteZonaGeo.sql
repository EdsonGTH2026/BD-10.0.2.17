CREATE TABLE [dbo].[tCaProdPerfilClienteZonaGeo] (
  [CodProducto] [char](3) NOT NULL,
  [CodUbiGeo] [varchar](6) NOT NULL,
  [CodArbolConta] [varchar](50) NULL,
  CONSTRAINT [PK_tCaProdPerfilClienteZonaGeo] PRIMARY KEY CLUSTERED ([CodProducto], [CodUbiGeo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdPerfilClienteZonaGeo]
  ADD CONSTRAINT [FK_tCaProdPerfilClienteZonaGeo_tCaProdPerfilCliente] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProdPerfilCliente] ([CodProducto])
GO