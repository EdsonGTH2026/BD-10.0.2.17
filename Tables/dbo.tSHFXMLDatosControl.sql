CREATE TABLE [dbo].[tSHFXMLDatosControl] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](298) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [Inicio] [varchar](91) NOT NULL,
  [Fin] [varchar](57) NOT NULL,
  [Emisor] [varchar](30) NOT NULL,
  [LineaNegocio] [varchar](30) NOT NULL,
  [TipoTransaccion] [varchar](36) NOT NULL,
  [TipoEnvio] [varchar](24) NOT NULL
)
ON [PRIMARY]
GO