CREATE TABLE [dbo].[Saldos] (
  [Sistema] [varchar](2) NOT NULL,
  [NoInternoPersona] [char](15) NULL,
  [Periodo] [varchar](6) COLLATE Modern_Spanish_CI_AS NOT NULL,
  [Saldo] [decimal](38, 4) NULL
)
ON [PRIMARY]
GO