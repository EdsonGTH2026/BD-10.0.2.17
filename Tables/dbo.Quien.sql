CREATE TABLE [dbo].[Quien] (
  [SpidI] [smallint] NULL,
  [Estado] [varchar](50) NULL,
  [Usuario] [varchar](100) NULL,
  [Servidor] [varchar](100) NULL,
  [Bloqueo] [varchar](5) NULL,
  [BaseDatos] [varchar](100) NULL,
  [Comando] [varchar](1000) NULL,
  [TiempoCPU] [int] NULL,
  [EntradaSalida] [int] NULL,
  [UltimoLote] [varchar](50) NULL,
  [Programa] [varchar](500) NULL,
  [SpidD] [smallint] NULL,
  [RequestID] [smallint] NULL
)
ON [PRIMARY]
GO