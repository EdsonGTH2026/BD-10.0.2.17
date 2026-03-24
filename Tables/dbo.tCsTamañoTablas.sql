CREATE TABLE [dbo].[tCsTamañoTablas] (
  [Fecha] [smalldatetime] NOT NULL,
  [Tabla] [varchar](60) NOT NULL,
  [Filas] [int] NULL,
  [Reservado] [int] NULL,
  [Data] [int] NULL,
  [TamañoIndice] [int] NULL,
  [NoUsado] [int] NULL,
  CONSTRAINT [PK_tCsTamañoTablas] PRIMARY KEY CLUSTERED ([Fecha], [Tabla])
)
ON [PRIMARY]
GO