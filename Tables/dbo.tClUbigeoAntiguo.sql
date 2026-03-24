CREATE TABLE [dbo].[tClUbigeoAntiguo] (
  [CodUbiGeo] [varchar](6) NOT NULL,
  [Orden] [smallint] NULL,
  [Siguiente] [varchar](6) NOT NULL,
  [Hijo] [varchar](6) NOT NULL,
  [CodUbiGeoTipo] [varchar](4) NULL,
  [NomUbiGeo] [varchar](40) NULL,
  [DescUbiGeo] [varchar](80) NULL,
  [AreaUbiGeo] [char](1) NULL,
  [Activa] [bit] NOT NULL,
  [Campo1] [varchar](15) NULL,
  [Campo2] [varchar](15) NULL,
  [Campo3] [varchar](15) NULL,
  [EsPrincipal] [bit] NULL,
  [CodArbolConta] [varchar](50) NULL,
  [CodPostal] [varchar](10) NULL
)
ON [PRIMARY]
GO