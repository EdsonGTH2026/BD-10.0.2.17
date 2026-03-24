CREATE TABLE [dbo].[_CC_DesA2023] (
  [Nivel_desactualizada] [varchar](10) NULL,
  [CuentaActual] [varchar](30) NULL,
  [TipoResponsabilidad] [varchar](3) NULL,
  [TipoCuenta] [varchar](3) NULL,
  [TipoContrato] [varchar](5) NULL,
  [FrecuenciaPagos] [varchar](1) NULL,
  [MontoPagar] [money] NULL,
  [FechaAperturaCuenta] [varchar](10) NULL,
  [FechaUltimoPago] [varchar](10) NULL,
  [FechaUltimaCompra] [varchar](10) NULL,
  [FechaCorte] [varchar](10) NULL,
  [CreditoMaximo] [varchar](5) NULL,
  [SaldoActual] [money] NULL,
  [PagoActual] [varchar](10) NULL,
  [ApellidoPaterno] [varchar](255) NULL,
  [ApellidoMaterno] [varchar](255) NULL,
  [ApellidoAdicional] [varchar](255) NULL,
  [Nombres] [varchar](255) NULL,
  [FechaNacimiento] [varchar](10) NULL
)
ON [PRIMARY]
GO