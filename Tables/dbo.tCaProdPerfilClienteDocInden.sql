CREATE TABLE [dbo].[tCaProdPerfilClienteDocInden] (
  [CodProducto] [char](3) NOT NULL,
  [CodDocIden] [varchar](5) NOT NULL,
  CONSTRAINT [PK_tCaProdPerfilClienteDocInden] PRIMARY KEY CLUSTERED ([CodProducto], [CodDocIden])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdPerfilClienteDocInden]
  ADD CONSTRAINT [FK_tCaProdPerfilClienteDocInden_tCaProdPerfilCliente] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProdPerfilCliente] ([CodProducto])
GO