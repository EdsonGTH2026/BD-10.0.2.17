CREATE TABLE [dbo].[tCaProdPerfilClienteEsCivil] (
  [CodProducto] [char](3) NOT NULL,
  [CodEstadoCivil] [char](1) NOT NULL,
  CONSTRAINT [PK_tCaProdPerfilClienteEsCivil] PRIMARY KEY CLUSTERED ([CodProducto], [CodEstadoCivil])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdPerfilClienteEsCivil] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdPerfilClienteEsCivil_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO

ALTER TABLE [dbo].[tCaProdPerfilClienteEsCivil] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdPerfilClienteEsCivil_tUsClEstadoCivil] FOREIGN KEY ([CodEstadoCivil]) REFERENCES [dbo].[tUsClEstadoCivil] ([CodEstadoCivil])
GO