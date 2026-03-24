CREATE TABLE [dbo].[tCsACaIncentivosvs2] (
  [fecha] [smalldatetime] NOT NULL,
  [codoficina] [varchar](3) NULL,
  [codasesor] [varchar](15) NULL,
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
  [saldo30] [money] NULL,
  [imor30] [money] NULL,
  [Imor1] [money] NULL,
  [Imor8] [money] NULL,
  [Imor16] [money] NULL,
  [nivelp2] [varchar](15) NULL,
  [puntosp2] [int] NULL,
  [puntaje] [int] NULL,
  [nivelBono] [varchar](15) NULL,
  [PorBono] [money] NULL,
  [saldo30ini] [money] NULL,
  [saldo30fin] [money] NULL,
  [nroptmos30ini] [int] NULL,
  [nroptmos30fin] [int] NULL,
  [Metacrecimiento] [int] NOT NULL,
  [Asignacionca] [decimal](38, 4) NOT NULL,
  [Quitaca] [decimal](38, 4) NOT NULL,
  [crecimiento] [decimal](38, 4) NOT NULL,
  [Alcancecreci] [decimal](38, 6) NOT NULL,
  [PorcentajeBono] [int] NOT NULL,
  [nroliquida] [int] NOT NULL,
  [nrorenova] [int] NOT NULL,
  [AlcanceRenov] [decimal](27, 9) NULL,
  [bonipena] [int] NOT NULL,
  [InteresCobrado] [money] NULL,
  [BonoPosiGanar] [money] NULL,
  [MontoBono] [money] NULL,
  [bonoobtenido] [money] NULL,
  [ayudatrans] [int] NOT NULL,
  [bonofinal] [money] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivosvs2] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsACaIncentivosvs2] TO [mchavezs2]
GO