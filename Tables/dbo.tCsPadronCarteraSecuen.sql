CREATE TABLE [dbo].[tCsPadronCarteraSecuen] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [SecuenciaProductivo] [int] NULL,
  [SecuenciaConsumo] [int] NULL,
  CONSTRAINT [PK_tCsPadronCarteraSecuen] PRIMARY KEY CLUSTERED ([CodPrestamo]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraSecuen] TO [marista]
GO