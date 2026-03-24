CREATE TABLE [dbo].[tCsCoReportes] (
  [Reporte] [char](2) NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [TieneGrupos] [char](1) NULL,
  [Archivo] [varchar](100) NULL,
  CONSTRAINT [PK_tCsCoReportes] PRIMARY KEY CLUSTERED ([Reporte])
)
ON [PRIMARY]
GO