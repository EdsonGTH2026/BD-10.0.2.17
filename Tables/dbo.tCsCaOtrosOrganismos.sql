CREATE TABLE [dbo].[tCsCaOtrosOrganismos] (
  [CodPrestamo] [varchar](50) NOT NULL,
  [Tipo] [varchar](2) NOT NULL,
  [CodFondo] [varchar](2) NULL,
  [Inicio] [smalldatetime] NULL,
  [Fin] [smalldatetime] NULL,
  [InicioContrato] [smalldatetime] NULL,
  [FinContrato] [smalldatetime] NULL,
  [Monto] [decimal](18, 4) NULL,
  [Recursos] [varchar](50) NULL,
  [Porcentaje] [decimal](18, 13) NULL,
  [TasaInteres] [varchar](50) NULL,
  [Garantia] [varchar](2) NULL,
  [NroContrato] [varchar](50) NULL,
  [NroPagare] [int] NULL,
  [NroCuotas] [int] NULL,
  [PlanPagosFijo] [bit] NULL,
  CONSTRAINT [PK_tCsCaOtrosOrganismos] PRIMARY KEY CLUSTERED ([CodPrestamo], [Tipo])
)
ON [PRIMARY]
GO