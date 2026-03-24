CREATE TABLE [dbo].[tINTFPLineaCredito] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](153) NOT NULL,
  [Usados] [int] NULL,
  [NumeroCuenta] [varchar](26) NOT NULL,
  [Responsabilidad] [varchar](2) NOT NULL,
  [TipoCuenta] [varchar](2) NOT NULL,
  [TipoContrato] [varchar](3) NOT NULL,
  [TipoMoneda] [varchar](3) NOT NULL,
  [NumeroPagos] [varchar](5) NOT NULL,
  [Frecuencia] [varchar](2) NOT NULL,
  [MontoPagar] [varchar](10) NOT NULL,
  [Apertura] [varchar](9) NOT NULL,
  [UltimoPago] [varchar](9) NOT NULL,
  [UltimaCompra] [varchar](9) NOT NULL,
  [Cierre] [varchar](9) NOT NULL,
  [Reporte] [varchar](9) NOT NULL,
  [Maximo] [varchar](10) NOT NULL,
  [Saldo] [varchar](11) NOT NULL,
  [Limite] [varchar](10) NOT NULL,
  [Vencido] [varchar](10) NOT NULL,
  [PagosVencidos] [varchar](5) NOT NULL,
  [MOP] [varchar](3) NOT NULL,
  [Observacion] [varchar](3) NOT NULL,
  [Fin] [varchar](3) NOT NULL
)
ON [PRIMARY]
GO