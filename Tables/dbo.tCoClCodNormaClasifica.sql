CREATE TABLE [dbo].[tCoClCodNormaClasifica] (
  [TipoCodNorma] [smallint] NOT NULL,
  [CodNorma] [smallint] NOT NULL,
  [DescripcionCorta] [varchar](50) NULL,
  [Descripcion] [varchar](30) NULL,
  [PorcEfectivo] [tinyint] NULL,
  [PorcTitulo] [tinyint] NULL
)
ON [PRIMARY]
GO