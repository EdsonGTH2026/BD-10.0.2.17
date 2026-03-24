CREATE TABLE [dbo].[tCaProdDestino] (
  [CodProducto] [char](3) NOT NULL,
  [CodDestino] [varchar](15) NOT NULL,
  CONSTRAINT [PK_tCaProdDestino] PRIMARY KEY CLUSTERED ([CodProducto], [CodDestino])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdDestino]
  ADD CONSTRAINT [FK_tCaProdDestino_tCaClDestino] FOREIGN KEY ([CodDestino]) REFERENCES [dbo].[tCaClDestino] ([CodDestino])
GO

ALTER TABLE [dbo].[tCaProdDestino] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdDestino_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO