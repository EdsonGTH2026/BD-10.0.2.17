CREATE TABLE [dbo].[tRcTipoEstructuraArchivoCP] (
  [TipoArchivoTexto] [varchar](3) NOT NULL,
  [EstructuraArchivo] [varchar](2) NOT NULL,
  [Tabla] [varchar](50) NULL,
  [TablaRecorrido] [varchar](50) NULL,
  [OrdenadoPor] [varchar](100) NULL,
  [Periodo] [varchar](6) NULL,
  [Activo] [bit] NULL
)
ON [PRIMARY]
GO