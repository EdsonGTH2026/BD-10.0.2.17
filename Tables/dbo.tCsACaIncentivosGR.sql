CREATE TABLE [dbo].[tCsACaIncentivosGR] (
  [fecha] [smalldatetime] NOT NULL,
  [zona] [char](3) NOT NULL,
  [responsable] [varchar](50) NULL,
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
  [Bono] [money] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivosGR] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivosGR] TO [mchavezs2]
GO