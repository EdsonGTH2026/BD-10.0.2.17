CREATE TABLE [dbo].[tcsvintage_prueba] (
  [Item] [int] NOT NULL,
  [Ubicacion] [varchar](4) NOT NULL,
  [Cartera] [varchar](50) NOT NULL,
  [Desembolso] [varchar](8) NOT NULL,
  [Periodo] [varchar](6) NOT NULL,
  [Corte] [varchar](8) NOT NULL,
  [Proceso] [smalldatetime] NULL,
  [Total] [int] NULL,
  [Buenos] [int] NULL,
  [Malos] [int] NULL,
  [Terminados] [int] NULL,
  [Vencidos] [int] NULL,
  [Ratio1] [decimal](20, 5) NULL,
  [Ratio2] [decimal](20, 5) NULL,
  [Producto] [varchar](50) NULL,
  [FechaCreacion] [smalldatetime] NULL
)
ON [PRIMARY]
GO