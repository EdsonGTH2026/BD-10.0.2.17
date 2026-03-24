CREATE TABLE [dbo].[tCsRptBonolidersucursal] (
  [CodOficina] [char](5) NULL,
  [Oficina] [varchar](30) NULL,
  [SaldoCarteraAnterior] [numeric](16, 2) NULL,
  [SaldoCarteraActual] [numeric](16, 2) NULL,
  [BonoxCrecimientoCartera] [numeric](16, 2) NULL,
  [NumAsesores] [int] NULL,
  [NumClientesNuevos] [int] NULL,
  [BonoxClientesNuevos] [numeric](16, 2) NULL,
  [MoraMesAnt] [numeric](16, 2) NULL,
  [MoraMesAct] [numeric](16, 2) NULL,
  [TipoTablaParaNormalidad] [varchar](50) NULL,
  [NormalidadTablaA] [numeric](16, 2) NULL,
  [PorcDeduccXNormalidadTablaA] [numeric](16, 2) NULL,
  [ReduccNormTablaB] [numeric](16, 2) NULL,
  [BonoXReduccNormalidadTablaB] [numeric](16, 2) NULL
)
ON [PRIMARY]
GO