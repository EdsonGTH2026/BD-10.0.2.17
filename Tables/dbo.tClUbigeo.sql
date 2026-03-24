CREATE TABLE [dbo].[tClUbigeo] (
  [CodUbiGeo] [varchar](6) NOT NULL,
  [CodUbiGeoTipo] [varchar](4) NOT NULL,
  [NomUbiGeo] [varchar](60) NULL,
  [DescUbiGeo] [varchar](60) NULL,
  [Campo1] [varchar](15) NULL,
  [Campo2] [varchar](15) NULL,
  [Campo3] [varchar](100) NULL,
  [CodArbolConta] [varchar](50) NULL,
  [CodEstado] [varchar](2) NULL,
  [CodMunicipio] [varchar](3) NULL,
  [IdLugar] [int] NULL,
  [Observacion] [varchar](200) NULL,
  [Activa] [bit] NOT NULL,
  [Anterior] [varchar](6) NULL,
  [ClaveSugerida] [varchar](10) NULL,
  [Latitud] [decimal](18, 6) NULL,
  [Longitud] [decimal](18, 6) NULL,
  CONSTRAINT [PK_tClUbigeo] PRIMARY KEY CLUSTERED ([CodUbiGeo], [CodUbiGeoTipo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_CodUbiGeoTipo_CodEstado]
  ON [dbo].[tClUbigeo] ([CodUbiGeoTipo], [CodEstado])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_CodUbiGeoTipo_CodMunicipio]
  ON [dbo].[tClUbigeo] ([CodUbiGeoTipo], [CodMunicipio])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tClUbigeo]
  ON [dbo].[tClUbigeo] ([CodArbolConta])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tClUbigeo_CodUbiGeoTipo_Campo1]
  ON [dbo].[tClUbigeo] ([CodUbiGeoTipo], [Campo1])
  INCLUDE ([CodUbiGeo], [DescUbiGeo])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tClUbigeo_CodUbiGeoTipo_DescUbiGeo_CodArbolConta]
  ON [dbo].[tClUbigeo] ([CodUbiGeoTipo], [DescUbiGeo], [CodArbolConta])
  INCLUDE ([CodUbiGeo])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClUbigeo] TO [marista]
GO

GRANT SELECT ON [dbo].[tClUbigeo] TO [jarriagaa]
GO

GRANT SELECT ON [dbo].[tClUbigeo] TO [public]
GO