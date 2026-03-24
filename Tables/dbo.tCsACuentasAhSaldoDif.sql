CREATE TABLE [dbo].[tCsACuentasAhSaldoDif] (
  [Fecha] [smalldatetime] NULL,
  [CodCuenta] [varchar](20) NULL,
  [FraccionCta] [varchar](3) NULL,
  [Renovado] [int] NULL,
  [idProducto] [varchar](3) NULL,
  [CodOficina] [varchar](3) NULL,
  [SaldoCuenta] [money] NULL,
  [MontoDPF] [money] NULL,
  [Monto] [money] NULL
)
ON [PRIMARY]
GO