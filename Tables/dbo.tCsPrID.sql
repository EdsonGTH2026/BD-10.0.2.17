CREATE TABLE [dbo].[tCsPrID] (
  [Id] [varchar](50) NOT NULL,
  [Fecha] [datetime] NULL,
  [Reporte] [varchar](50) NOT NULL,
  [Parametro] [varchar](50) NOT NULL,
  [Valor] [varchar](500) NULL,
  [Veces] [int] NULL,
  [Firma] [varchar](100) NULL,
  CONSTRAINT [PK_tCsPrID] PRIMARY KEY CLUSTERED ([Id], [Reporte], [Parametro])
)
ON [PRIMARY]
GO