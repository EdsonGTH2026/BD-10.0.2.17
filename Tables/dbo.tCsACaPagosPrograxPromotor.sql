CREATE TABLE [dbo].[tCsACaPagosPrograxPromotor] (
  [fecha] [smalldatetime] NULL,
  [region] [varchar](50) NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](30) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [promotor] [varchar](300) NULL,
  [NombreCliente] [varchar](300) NULL,
  [telefonomovil] [varchar](50) NULL,
  [atraso] [varchar](4) NOT NULL,
  [amortizacion] [money] NULL,
  [SaldoPonerCorriente] [money] NOT NULL,
  [cuotasvencidas] [int] NULL,
  [Ref_BANAMEX] [varchar](50) NULL,
  [Ref_BANCOMER] [varchar](50) NULL
)
ON [PRIMARY]
GO