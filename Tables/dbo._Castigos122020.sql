CREATE TABLE [dbo].[_Castigos122020] (
  [codprestamo] [varchar](25) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [saldocapital] [money] NOT NULL,
  [interesvencido] [money] NULL,
  [interesctaorden] [money] NULL,
  [cargomora] [money] NULL,
  [otroscargos] [money] NOT NULL,
  [montogarantia] [money] NULL,
  [tipogarantia] [varchar](5) NULL
)
ON [PRIMARY]
GO