CREATE TABLE [dbo].[tCsCaOtrosOrganismosCuotas] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [Tipo] [varchar](2) NOT NULL,
  [NroCuota] [int] NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Capital] [decimal](18, 4) NULL,
  CONSTRAINT [PK_tCsCaOtrosOrganismosCuotas] PRIMARY KEY CLUSTERED ([CodPrestamo], [Tipo], [Fecha])
)
ON [PRIMARY]
GO