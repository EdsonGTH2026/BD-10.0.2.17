CREATE TABLE [dbo].[tCsACaPagosPrograPromSemana] (
  [fecha] [smalldatetime] NULL,
  [fechavencimiento] [smalldatetime] NULL,
  [region] [varchar](50) NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](100) NULL,
  [Promotor] [varchar](300) NULL,
  [Programado_N] [int] NULL,
  [Anticipado] [int] NULL,
  [Puntual] [int] NULL,
  [Atrasado] [int] NULL,
  [Pagado_N] [int] NULL,
  [SinPago_N] [int] NULL,
  [PagoParcial_N] [int] NULL,
  [PorPagado_N] [decimal](16, 6) NULL,
  [Programado_S] [money] NULL,
  [Pagado_S] [money] NULL,
  [PorPagado_S] [money] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACaPagosPrograPromSemana] TO [jarriagaa]
GO