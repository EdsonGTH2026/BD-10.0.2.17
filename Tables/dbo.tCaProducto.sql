CREATE TABLE [dbo].[tCaProducto] (
  [CodProducto] [char](3) NOT NULL,
  [NombreProd] [varchar](50) NOT NULL,
  [NombreProdCorto] [varchar](50) NULL,
  [TipoTecnoCred] [varchar](10) NULL,
  [Tecnologia] [char](1) NULL,
  [TipoContrato] [varchar](2) NULL,
  [idLineaCredito] [varchar](10) NULL,
  [DestinoComentario] [varchar](100) NULL,
  [GarantiaDPF] [bit] NULL,
  [Garantia21] [bit] NULL,
  [GarantiaPrendaria] [bit] NULL,
  [GarantiaAval] [bit] NULL,
  [MejoramientoVivienda] [bit] NULL,
  [DocCustodia] [bit] NULL,
  [Estado] [varchar](10) NULL,
  [TipoAmortizacion] [varchar](50) NULL,
  [RECA] [varchar](50) NULL,
  CONSTRAINT [PK_tCaProducto] PRIMARY KEY CLUSTERED ([CodProducto])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaProducto] TO [marista]
GO

GRANT SELECT ON [dbo].[tCaProducto] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCaProducto] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCaProducto] TO [rie_jalvarezc]
GO