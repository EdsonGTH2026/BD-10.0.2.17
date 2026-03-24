CREATE TABLE [dbo].[tCsDiaGarantias] (
  [Fecha] [smalldatetime] NOT NULL,
  [Referencia] [smalldatetime] NOT NULL,
  [Codigo] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [TipoGarantia] [varchar](5) NOT NULL,
  [DocPropiedad] [varchar](25) NOT NULL,
  [Garantia] [money] NULL,
  [DescGarantia] [varchar](200) NULL,
  [Formalizada] [char](2) NOT NULL,
  [Tabla] [char](2) NOT NULL,
  [Estado] [varchar](50) NULL,
  CONSTRAINT [PK_tCsDiaGarantias2] PRIMARY KEY CLUSTERED ([Fecha], [Referencia], [Codigo], [CodOficina], [TipoGarantia], [DocPropiedad])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsDiaGarantias_Codigo]
  ON [dbo].[tCsDiaGarantias] ([Codigo])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsDiaGarantias] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsDiaGarantias] TO [rie_jaguilar]
GO

GRANT SELECT ON [dbo].[tCsDiaGarantias] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsDiaGarantias] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsDiaGarantias] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsDiaGarantias] TO [rie_blozanob]
GO