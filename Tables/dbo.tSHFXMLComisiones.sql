CREATE TABLE [dbo].[tSHFXMLComisiones] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](170) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [ComisionClave] [varchar](67) NOT NULL,
  [ComisionValor] [varchar](50) NOT NULL
)
ON [PRIMARY]
GO