CREATE TABLE [dbo].[tCsPadronCarteraDestinoDet] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodDestino] [varchar](50) NULL,
  [CodProveedor] [int] NULL,
  [CodUnidad] [int] NULL,
  [Observacion] [varchar](100) NULL,
  CONSTRAINT [PK_tCsPadronCarteraDestinoDet] PRIMARY KEY CLUSTERED ([CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO