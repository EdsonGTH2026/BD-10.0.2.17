CREATE TABLE [dbo].[tCaProductoPerfilMonedas] (
  [CodProducto] [char](3) NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  CONSTRAINT [PK_tCaProductoPerfilMonedas] PRIMARY KEY CLUSTERED ([CodProducto], [CodMoneda])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProductoPerfilMonedas] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProductoPerfilMonedas_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO

ALTER TABLE [dbo].[tCaProductoPerfilMonedas]
  ADD CONSTRAINT [FK_tCaProductoPerfilMonedas_tClMonedas] FOREIGN KEY ([CodMoneda]) REFERENCES [dbo].[tClMonedas] ([CodMoneda])
GO