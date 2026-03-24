CREATE TABLE [dbo].[tCaProdMetodosPago] (
  [CodProducto] [char](3) NOT NULL,
  [CPconcetracionMAX] [int] NULL CONSTRAINT [DF_tCaProdMetodosPago_CPconcetracionMAX] DEFAULT (0),
  [CPDivisionMIN] [int] NULL CONSTRAINT [DF_tCaProdMetodosPago_CPDivisionMIN] DEFAULT (0),
  [FFDias] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FFDias] DEFAULT (0),
  [FFDiaINI] [int] NULL,
  [FFUltimoDia] [int] NULL CONSTRAINT [DF_tCaProdMetodosPago_FFUltimoDia] DEFAULT (0),
  [FFUltimoDiaMes] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FFUltimoDiaMes] DEFAULT (0),
  [FPAlVencimiento] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FPAlVencimiento] DEFAULT (0),
  [FPAlDiaPago] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FPAlDiaPago] DEFAULT (0),
  [FPDiasCalculo] [int] NULL CONSTRAINT [DF_tCaProdMetodosPago_FPDiasCalculo] DEFAULT (360),
  [FRCifraSUP] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FRCifraSUP] DEFAULT (0),
  [FRCifraINF] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FRCifraINF] DEFAULT (0),
  [FRal05] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FRal05] DEFAULT (0),
  [FRNumDigitos] [bit] NULL CONSTRAINT [DF_tCaProdMetodosPago_FRNumDigitos] DEFAULT (0),
  [FRNDigitos] [int] NULL CONSTRAINT [DF_tCaProdMetodosPago_FRNDigitos] DEFAULT (0),
  CONSTRAINT [PK_tCaProdMetodosPago] PRIMARY KEY CLUSTERED ([CodProducto])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdMetodosPago] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdMetodosPago_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO