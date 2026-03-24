CREATE TABLE [dbo].[tCsPrIntervalo] (
  [Intervalo] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Temporada] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  CONSTRAINT [PK_tCsPrIntervalo] PRIMARY KEY CLUSTERED ([Intervalo])
)
ON [PRIMARY]
GO