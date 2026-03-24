CREATE TABLE [dbo].[tSHFXMLCorte] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](280) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [SIFin] [varchar](58) NOT NULL,
  [NroDiasAtraso] [varchar](55) NOT NULL,
  [CuotasPagadas] [varchar](39) NOT NULL,
  [UltimoPago] [varchar](65) NOT NULL
)
ON [PRIMARY]
GO