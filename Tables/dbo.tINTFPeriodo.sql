CREATE TABLE [dbo].[tINTFPeriodo] (
  [Corte] [smalldatetime] NOT NULL,
  [Periodo] [varchar](6) NULL,
  [FechaReporte] [smalldatetime] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tINTFPeriodo] PRIMARY KEY CLUSTERED ([Corte])
)
ON [PRIMARY]
GO