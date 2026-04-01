CREATE TABLE [dbo].[tCsFirmaReporteClausula] (
  [Firma] [varchar](100) NOT NULL,
  [Fila] [int] NOT NULL,
  [Clausula] [varchar](50) NOT NULL,
  [Tipo] [varchar](50) NOT NULL,
  [Orden] [int] NULL,
  [Titulo] [varchar](50) NULL,
  [Texto] [varchar](8000) NULL,
  [Texto1] [varchar](8000) NULL
)
ON [PRIMARY]
GO