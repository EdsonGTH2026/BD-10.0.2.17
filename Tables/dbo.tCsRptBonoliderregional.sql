CREATE TABLE [dbo].[tCsRptBonoliderregional] (
  [Zona] [char](5) NULL,
  [NombreZona] [varchar](50) NULL,
  [SaldoCarteraAnterior] [numeric](16, 2) NULL,
  [SaldoCarteraActual] [numeric](16, 2) NULL,
  [BonoxCrecimientoCartera] [numeric](16, 2) NULL,
  [NumClientesNuevos] [int] NULL,
  [BonoxClientesNuevos] [int] NULL,
  [MoraMesAnt] [numeric](16, 2) NULL,
  [MoraMesAct] [numeric](16, 2) NULL,
  [TipoTablaParaNormalidad] [varchar](50) NULL,
  [MargenTablaA] [numeric](17, 2) NULL,
  [MargenTablaB] [decimal](10, 2) NULL,
  [penalizacion] [numeric](16, 2) NULL,
  [bono] [numeric](16, 2) NULL
)
ON [PRIMARY]
GO