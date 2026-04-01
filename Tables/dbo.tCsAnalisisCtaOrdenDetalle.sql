CREATE TABLE [dbo].[tCsAnalisisCtaOrdenDetalle] (
  [Dia] [int] NOT NULL,
  [CorteDataNegocio] [smalldatetime] NOT NULL,
  [ProcesoFinmas] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](25) NOT NULL,
  [Cuota] [int] NOT NULL,
  [NroDiasAtraso] [int] NOT NULL,
  [DK] [decimal](18, 8) NULL,
  [SaldoK] [decimal](18, 8) NULL,
  [PagoK] [decimal](18, 8) NULL,
  [DIC] [decimal](18, 8) NULL,
  [SaldoIC] [decimal](18, 8) NULL,
  [PagoIC] [decimal](18, 8) NULL,
  [SICCB] [decimal](18, 8) NULL,
  [SICCO] [decimal](18, 8) NULL,
  [DIM] [decimal](18, 8) NULL,
  [SaldoIM] [decimal](18, 8) NULL,
  [PagoIM] [decimal](18, 8) NULL,
  [SIMCB] [decimal](18, 8) NULL,
  [SIMCO] [decimal](18, 8) NULL,
  [Observacion] [varchar](500) NULL
)
ON [PRIMARY]
GO