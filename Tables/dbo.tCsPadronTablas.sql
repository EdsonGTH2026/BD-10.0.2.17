CREATE TABLE [dbo].[tCsPadronTablas] (
  [Tabla] [varchar](50) NOT NULL,
  [TipoTabla] [int] NULL,
  [FechaConsolidacion] [smalldatetime] NULL,
  [Descripcion] [text] NULL,
  [Observacion] [text] NULL,
  [ActualFila] [float] NULL,
  [ActualData] [float] NULL,
  [Promedio] [float] NULL,
  CONSTRAINT [PK_tCsPadronTablas] PRIMARY KEY CLUSTERED ([Tabla])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO