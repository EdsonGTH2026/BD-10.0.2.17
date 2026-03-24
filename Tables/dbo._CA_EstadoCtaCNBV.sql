CREATE TABLE [dbo].[_CA_EstadoCtaCNBV] (
  [CodPrestamo] [varchar](20) NULL,
  [Cancelacion] [datetime] NULL,
  [MontoOriginal] [money] NULL,
  [CodFondo] [int] NULL,
  [Cliente] [varchar](250) NULL,
  [Estado] [tinyint] NULL
)
ON [PRIMARY]
GO