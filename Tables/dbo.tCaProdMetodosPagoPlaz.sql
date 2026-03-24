CREATE TABLE [dbo].[tCaProdMetodosPagoPlaz] (
  [CodProducto] [char](3) NOT NULL,
  [CodTipoPlaz] [char](1) NOT NULL,
  [DescTipoPlaz] [varchar](15) NULL,
  [DiaTipoPlaz] [smallint] NULL,
  [Elegido] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPagoPlaz_Elegido] DEFAULT (0),
  [UltElegido] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPagoPlaz_UltElegido] DEFAULT (0),
  CONSTRAINT [PK_tCaProdMetodosPagoPlaz] PRIMARY KEY CLUSTERED ([CodProducto], [CodTipoPlaz])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdMetodosPagoPlaz]
  ADD CONSTRAINT [FK_tCaProdMetodosPagoPlaz_tCAClTipoPlaz] FOREIGN KEY ([CodTipoPlaz]) REFERENCES [dbo].[tCAClTipoPlaz] ([CodTipoPlaz])
GO

ALTER TABLE [dbo].[tCaProdMetodosPagoPlaz] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdMetodosPagoPlaz_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO