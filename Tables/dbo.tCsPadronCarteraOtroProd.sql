CREATE TABLE [dbo].[tCsPadronCarteraOtroProd] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [codproducto] [varchar](3) NULL,
  CONSTRAINT [PK_tCsPadronCarteraOtroProd] PRIMARY KEY CLUSTERED ([CodPrestamo])
)
ON [PRIMARY]
GO