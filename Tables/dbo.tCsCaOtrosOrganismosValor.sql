CREATE TABLE [dbo].[tCsCaOtrosOrganismosValor] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](50) NOT NULL,
  [Tipo] [varchar](2) NOT NULL,
  [Porcentaje] [decimal](18, 12) NULL,
  [CtaCapital] [varchar](50) NULL,
  [MtoCapital] [decimal](18, 4) NULL,
  [CtaInteres] [varchar](50) NULL,
  [MtoInteres] [decimal](18, 4) NULL,
  CONSTRAINT [PK_tCsCaOtrosOrganismosValor] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo], [Tipo])
)
ON [PRIMARY]
GO