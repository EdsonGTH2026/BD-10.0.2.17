CREATE TABLE [dbo].[tCsCaCobPrograPaga] (
  [fecha] [smalldatetime] NOT NULL,
  [region] [varchar](50) NOT NULL,
  [codoficina] [varchar](4) NOT NULL,
  [sucursal] [varchar](30) NOT NULL,
  [cartera] [varchar](10) NOT NULL,
  [codasesor] [varchar](15) NOT NULL,
  [nrodiasatraso] [int] NOT NULL,
  [ciclo] [int] NOT NULL,
  [codproducto] [char](3) NOT NULL,
  [Condonado] [money] NULL,
  [Pagado] [money] NULL,
  [saldo] [money] NULL,
  [Programado_N] [int] NULL,
  [Programado_S] [money] NULL,
  [Pagado_S] [money] NULL,
  [Pa_S_Anti] [money] NULL,
  [Pa_S_Punt] [money] NULL,
  [Pa_S_Atra] [money] NULL,
  [Pagado_N] [int] NULL,
  [Pa_N_Anti] [int] NULL,
  [Pa_N_Punt] [int] NULL,
  [Pa_N_Atra] [int] NULL,
  [SinPago_N] [int] NULL,
  [SinPago_S] [money] NULL,
  [PagoParcial_N] [int] NULL,
  [Par_N_Anti] [int] NULL,
  [Par_N_Punt] [int] NULL,
  [Par_N_Atra] [int] NULL,
  [PagoParcial_S] [money] NULL,
  [Par_S_Anti] [money] NULL,
  [Par_S_Punt] [money] NULL,
  [Par_S_Atra] [money] NULL,
  [Par_S_ND] [money] NULL,
  CONSTRAINT [PK_tCsCaCobPrograPaga] PRIMARY KEY CLUSTERED ([fecha], [region], [codoficina], [sucursal], [cartera], [codasesor], [nrodiasatraso], [ciclo], [codproducto]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsCaCobPrograPaga] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsCaCobPrograPaga] TO [jarriagaa]
GO