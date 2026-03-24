CREATE TABLE [dbo].[tCaProdPerfilClienteZonaGeoAux] (
  [Usuario] [varchar](20) NOT NULL,
  [CodProducto] [char](3) NULL,
  [CodUbiGeo] [varchar](6) NULL,
  [DescUbiGeo] [varchar](80) NULL,
  [Seleccionado] [bit] NULL,
  [CodArbolConta] [varchar](50) NULL
)
ON [PRIMARY]
GO