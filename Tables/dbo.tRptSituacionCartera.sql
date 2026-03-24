CREATE TABLE [dbo].[tRptSituacionCartera] (
  [Cartera] [varchar](14) NULL,
  [Ubicacion] [varchar](17) NULL,
  [Fecha] [smalldatetime] NULL,
  [Tecnologia] [varchar](50) NULL,
  [Informacion] [varchar](1031) NULL,
  [Desembolso] [decimal](38, 4) NULL,
  [Saldo] [decimal](38, 4) NULL,
  [Reporte] [varchar](5) NULL,
  [Identificador] [varchar](10) NULL,
  [Clientes] [int] NULL,
  [Prestamos] [int] NULL,
  [CampoReporte] [varchar](50) NULL,
  [GrupoReporte] [varchar](400) NULL
)
ON [PRIMARY]
GO