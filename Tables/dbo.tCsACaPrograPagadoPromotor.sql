CREATE TABLE [dbo].[tCsACaPrograPagadoPromotor] (
  [fecha] [smalldatetime] NULL,
  [region] [varchar](50) NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](30) NULL,
  [Promotor] [varchar](300) NULL,
  [codasesor] [varchar](15) NULL,
  [fechavencimiento] [smalldatetime] NOT NULL,
  [Programados] [int] NULL,
  [Programado] [money] NULL,
  [Pagado] [money] NULL,
  [Condonado] [money] NULL,
  [saldo] [money] NULL,
  [Pagados] [int] NULL,
  [SinPago] [int] NULL,
  [PagoParcial] [int] NULL
)
ON [PRIMARY]
GO