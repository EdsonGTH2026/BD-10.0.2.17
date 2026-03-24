CREATE TABLE [dbo].[tTmpTamañoTablas] (
  [Tabla] [varchar](60) NOT NULL,
  [Filas] [varchar](15) NULL,
  [Reservado] [varchar](15) NULL,
  [Data] [varchar](15) NULL,
  [TamañoIndice] [varchar](15) NULL,
  [NoUsado] [varchar](15) NULL,
  CONSTRAINT [PK_tTmpTamañoTablas] PRIMARY KEY CLUSTERED ([Tabla])
)
ON [PRIMARY]
GO