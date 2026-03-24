CREATE TABLE [dbo].[tCsPrTipoSaldo] (
  [TipoSaldo] [varchar](2) NOT NULL,
  [Sistema] [varchar](2) NULL,
  [Nombre] [varchar](50) NULL,
  [Titulo] [varchar](100) NULL,
  [Reporte] [varchar](10) NULL,
  [Formula] [varchar](200) NULL,
  [Tabla] [varchar](50) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsPrTipoSaldo] PRIMARY KEY CLUSTERED ([TipoSaldo])
)
ON [PRIMARY]
GO