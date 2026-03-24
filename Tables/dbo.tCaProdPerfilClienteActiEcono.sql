CREATE TABLE [dbo].[tCaProdPerfilClienteActiEcono] (
  [CodProducto] [char](3) NOT NULL,
  [CodAlterno] [varchar](7) NOT NULL,
  CONSTRAINT [PK_tCaProdPerfilClienteActiEcono] PRIMARY KEY CLUSTERED ([CodProducto], [CodAlterno])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdPerfilClienteActiEcono] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdPerfilClienteActiEcono_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO