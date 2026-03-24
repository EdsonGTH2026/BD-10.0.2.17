CREATE TABLE [dbo].[tCoClCodNormaGrupo] (
  [TipoCodNorma] [smallint] NOT NULL,
  [CodNormaGrupo] [smallint] NOT NULL,
  [Descripcion] [varchar](50) NULL,
  [DescripcionCorta] [varchar](50) NULL,
  [SeImprime] [bit] NULL
)
ON [PRIMARY]
GO