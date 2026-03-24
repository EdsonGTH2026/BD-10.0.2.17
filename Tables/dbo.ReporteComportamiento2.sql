CREATE TABLE [dbo].[ReporteComportamiento2] (
  [CodigoCuenta] [varchar](25) NOT NULL,
  [CodUsuario] [char](25) NOT NULL,
  [FechaMovimiento] [smalldatetime] NOT NULL,
  [TipoMovimiento] [int] NOT NULL,
  [ClaveMovimiento] [int] NULL,
  [TipoMovimientoAplica] [int] NOT NULL,
  [MontoMovimiento] [decimal](20, 4) NULL,
  [DenominacionMovimiento] [int] NULL
)
ON [PRIMARY]
GO