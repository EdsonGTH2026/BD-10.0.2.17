CREATE TABLE [dbo].[tSHFXMLInicioPeriodo] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](330) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [SIInicio] [varchar](131) NOT NULL,
  [Cargos] [varchar](37) NOT NULL,
  [Abonos] [varchar](37) NOT NULL,
  [Disposiciones] [varchar](51) NOT NULL,
  [PagosProgramado] [varchar](50) NOT NULL
)
ON [PRIMARY]
GO