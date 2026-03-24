CREATE TABLE [dbo].[tCsACaIncentivosGS] (
  [fecha] [smalldatetime] NOT NULL,
  [codoficina] [varchar](3) NOT NULL,
  [saldoini] [money] NULL CONSTRAINT [DF_tCsACaIncentivosGS_saldoini] DEFAULT (0),
  [programado_s] [money] NULL,
  [pagado_s] [money] NULL,
  [PorCobranza] [money] NULL,
  [Nivel_CO] [varchar](10) NOT NULL,
  [Puntaje_CO] [int] NOT NULL,
  [saldo] [money] NULL,
  [saldovencido] [money] NULL,
  [PorImor] [money] NULL,
  [Nivel_IM] [varchar](10) NOT NULL,
  [Puntaje_IM] [int] NOT NULL,
  [Bono_1ra] [money] NULL,
  [Bono_2da] [money] NULL,
  [TotalBonos] [money] NULL,
  [PuntajeTotal] [int] NULL,
  [PorBono] [int] NOT NULL,
  [Bono] [money] NULL,
  CONSTRAINT [PK_tCsACaIncentivosGS] PRIMARY KEY CLUSTERED ([fecha], [codoficina]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivosGS] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivosGS] TO [mchavezs2]
GO