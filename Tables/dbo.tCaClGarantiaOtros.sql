CREATE TABLE [dbo].[tCaClGarantiaOtros] (
  [CodProducto] [char](3) NOT NULL,
  [TipoGarantia] [varchar](5) NOT NULL,
  [secuencial] [tinyint] NOT NULL,
  [Descripcion] [varchar](30) NOT NULL,
  [TipoDato] [char](10) NOT NULL,
  [Longitud] [tinyint] NOT NULL,
  [Requerido] [bit] NOT NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [smallint] NOT NULL
)
ON [PRIMARY]
GO