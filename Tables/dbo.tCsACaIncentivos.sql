CREATE TABLE [dbo].[tCsACaIncentivos] (
  [Fecha] [smalldatetime] NOT NULL,
  [codoficina] [varchar](3) NOT NULL,
  [codasesor] [varchar](15) NOT NULL,
  [coordinador] [varchar](250) NULL,
  [saldocapital] [money] NULL,
  [desembolso] [money] NULL,
  [pordeudese] [money] NULL,
  [categoria] [varchar](15) NULL,
  [PorBonoInte] [money] NULL,
  [programado_s] [money] NULL,
  [pagado_s] [money] NULL,
  [porpagado_s] [money] NULL,
  [nivelCO] [varchar](15) NULL,
  [puntosCO] [int] NULL,
  [saldo] [money] NULL,
  [saldovencido] [money] NULL,
  [imor30] [money] NULL,
  [nivelp2] [varchar](15) NULL,
  [puntosp2] [int] NULL,
  [puntaje] [int] NULL,
  [nivelBono] [varchar](15) NULL,
  [PorBono] [money] NULL,
  [saldoini] [money] NULL,
  [saldofin] [money] NULL,
  [crecimiento] [money] NULL,
  [montointecob] [money] NULL,
  [PorcBonoFinal] [money] NULL,
  [BonoFinal] [money] NULL,
  [PorCrecimiento] [money] NOT NULL,
  [montointecob_1ra] [money] NULL,
  [PorcBonoFinal_1ra] [money] NULL,
  [BonoFinal_1ra] [money] NULL,
  [ReeBono_1ra] [money] NULL,
  [montointecobtotal] [money] NULL,
  [BonoConCrecimiento] [money] NULL,
  [BonoDiferencia] [money] NULL,
  [ReeProgramado_s] [money] NULL,
  [ReePagado_s] [money] NULL,
  [ReePorPagado_s] [money] NULL,
  [ReePorBonoIntCob] [money] NULL,
  [ReeMontoIntCob] [money] NULL,
  [PorReeCumpli] [money] NULL,
  [ReeBono] [money] NULL,
  CONSTRAINT [PK_tCsACaIncentivos] PRIMARY KEY CLUSTERED ([Fecha], [codoficina], [codasesor]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivos] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivos] TO [mchavezs2]
GO