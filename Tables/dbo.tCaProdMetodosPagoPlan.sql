CREATE TABLE [dbo].[tCaProdMetodosPagoPlan] (
  [CodProducto] [char](3) NOT NULL,
  [CodTipoPlan] [char](1) NOT NULL,
  [DescTipoPlan] [varchar](50) NULL,
  [Elegido] [bit] NOT NULL CONSTRAINT [DF_tCaProdMetodosPagoPlan_Elegido] DEFAULT (0),
  [UltElegido] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPagoPlan_UltElegido] DEFAULT (0),
  CONSTRAINT [PK_tCaProdMetodosPagoPlan] PRIMARY KEY CLUSTERED ([CodProducto], [CodTipoPlan])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdMetodosPagoPlan] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdMetodosPagoPlan_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO