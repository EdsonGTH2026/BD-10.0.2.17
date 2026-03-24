CREATE TABLE [dbo].[tSHFXMLTasasInteres] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](136) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [TasaClave] [varchar](39) NOT NULL,
  [TasaValor] [varchar](40) NOT NULL
)
ON [PRIMARY]
GO