CREATE TABLE [dbo].[tASSISTTransactionCode] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](58) NOT NULL,
  [Usados] [int] NULL,
  [CodigoTransaccion] [varchar](8) NOT NULL,
  [Descripcion] [varchar](40) NOT NULL,
  [CodigoTipo] [char](1) NOT NULL,
  [ReporteExepcion] [char](1) NOT NULL,
  [CodigoGrupo] [varchar](8) NOT NULL
)
ON [PRIMARY]
GO