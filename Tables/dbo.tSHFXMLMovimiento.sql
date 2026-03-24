CREATE TABLE [dbo].[tSHFXMLMovimiento] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](358) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [MovFecha] [varchar](81) NOT NULL,
  [MovTipo] [varchar](34) NOT NULL,
  [MovClave] [varchar](38) NOT NULL,
  [MovAplica] [varchar](46) NOT NULL,
  [MovMonto] [varchar](45) NOT NULL,
  [MovDenominacion] [varchar](63) NOT NULL
)
ON [PRIMARY]
GO