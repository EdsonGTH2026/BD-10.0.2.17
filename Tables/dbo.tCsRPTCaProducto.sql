CREATE TABLE [dbo].[tCsRPTCaProducto] (
  [Variable] [varchar](50) NOT NULL,
  [Tipos] [int] NULL,
  [NroVariable] [int] NULL,
  [Fila] [int] NOT NULL,
  [Condicion] [varchar](500) NULL,
  [RVerdad] [varchar](900) NULL,
  [RVerdad1] [varchar](900) NULL,
  [RFalso] [varchar](900) NULL,
  CONSTRAINT [PK_tCsRPTCaProducto] PRIMARY KEY CLUSTERED ([Variable], [Fila])
)
ON [PRIMARY]
GO