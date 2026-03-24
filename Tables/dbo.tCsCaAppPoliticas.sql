CREATE TABLE [dbo].[tCsCaAppPoliticas] (
  [Id] [int] IDENTITY,
  [CodProducto] [varchar](3) NOT NULL,
  [CicloMin] [int] NOT NULL,
  [CicloMax] [int] NOT NULL,
  [MontoMin] [int] NOT NULL,
  [MontoMax] [int] NOT NULL,
  [Periodicidad] [varchar](20) NOT NULL,
  [Plazo] [varchar](50) NOT NULL,
  [Tasa] [money] NOT NULL,
  [GarantiaLiquida] [money] NOT NULL,
  [PorcenIncreReno] [money] NOT NULL,
  [PorcenDecreReno] [money] NOT NULL,
  [VisitaPromotor] [bit] NOT NULL,
  [SegundaVisitaVF] [bit] NOT NULL,
  [IdentiOficial] [bit] NOT NULL,
  [CURP] [bit] NOT NULL,
  [CompDomicilio] [bit] NOT NULL,
  [CompIngresos] [bit] NOT NULL,
  [AutorizacionSIC] [bit] NOT NULL,
  [FotoCliente] [bit] NOT NULL,
  CONSTRAINT [PK_tCsCaAppPoliticas] PRIMARY KEY CLUSTERED ([Id])
)
ON [PRIMARY]
GO