CREATE TABLE [dbo].[_Castigos122022_adi_pos] (
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
  [estado] [varchar](50) NULL,
  [condona_seguro] [bit] NULL,
  [Condona_rst] [bit] NULL,
  [condona_cargomora] [bit] NULL,
  [condona_interes] [bit] NULL,
  [aplica_garantia] [bit] NULL,
  [Castigado] [bit] NULL
)
ON [PRIMARY]
GO