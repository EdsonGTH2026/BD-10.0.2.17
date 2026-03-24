CREATE TABLE [dbo].[tCaProdPerfilClienteNacion] (
  [CodProducto] [char](3) NOT NULL,
  [CodPais] [int] NOT NULL,
  CONSTRAINT [PK_tCaProdPerfilClienteNacion] PRIMARY KEY CLUSTERED ([CodProducto], [CodPais])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdPerfilClienteNacion] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdPerfilClienteNacion_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO