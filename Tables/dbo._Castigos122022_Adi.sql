CREATE TABLE [dbo].[_Castigos122022_Adi] (
  [codprestamo] [varchar](25) NOT NULL,
  [nrodiasatraso] [int] NULL,
  [saldocapital] [money] NOT NULL,
  [interesvigente] [money] NULL,
  [interesvencido] [money] NULL,
  [interesctaorden] [money] NULL,
  [cargomora] [money] NULL,
  [otroscargos] [money] NOT NULL,
  [rst] [money] NOT NULL,
  [montogarantia] [money] NULL,
  [tipogarantia] [varchar](5) NULL,
  [tiporeprog] [char](5) NULL,
  [estado] [varchar](50) NULL
)
ON [PRIMARY]
GO