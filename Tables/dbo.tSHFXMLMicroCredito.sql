CREATE TABLE [dbo].[tSHFXMLMicroCredito] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](208) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [idLineaCredito] [varchar](69) NOT NULL,
  [Originador] [varchar](34) NOT NULL,
  [Codigo] [varchar](56) NOT NULL,
  [SolucionVivienda] [varchar](54) NULL
)
ON [PRIMARY]
GO