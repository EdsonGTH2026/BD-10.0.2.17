CREATE TABLE [dbo].[tSHFXMLDatosMicroCredito] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](535) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [Monto] [varchar](113) NOT NULL,
  [Divisa] [varchar](42) NOT NULL,
  [Frecuencia] [varchar](34) NOT NULL,
  [MontoPago] [varchar](33) NOT NULL,
  [Desembolso] [varchar](59) NOT NULL,
  [Mininistracion] [varchar](75) NOT NULL,
  [Vencimiento] [varchar](73) NOT NULL,
  [Destino] [varchar](34) NOT NULL,
  [Plazo] [varchar](41) NOT NULL
)
ON [PRIMARY]
GO