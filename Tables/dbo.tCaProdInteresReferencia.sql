CREATE TABLE [dbo].[tCaProdInteresReferencia] (
  [CodProducto] [char](3) NOT NULL,
  [Agrupador] [varchar](25) NOT NULL,
  [DescAgrupador] [varchar](25) NOT NULL,
  [Relacion1] [varchar](25) NOT NULL,
  [DescRelacion1] [varchar](25) NOT NULL,
  [Relacion2] [varchar](25) NOT NULL,
  [DescRelacion2] [varchar](25) NOT NULL,
  CONSTRAINT [PK_tCaProdInteresReferencia] PRIMARY KEY CLUSTERED ([CodProducto], [Agrupador], [DescAgrupador], [Relacion1], [DescRelacion1], [Relacion2], [DescRelacion2])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdInteresReferencia] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdInteresReferencia_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO