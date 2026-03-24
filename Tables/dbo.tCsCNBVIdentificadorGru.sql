CREATE TABLE [dbo].[tCsCNBVIdentificadorGru] (
  [periodo] [int] NOT NULL,
  [codsistema] [char](2) NOT NULL,
  [codprestamo] [varchar](20) NOT NULL,
  [identificador] [varchar](50) NULL,
  CONSTRAINT [PK_tCsCNBVIdentificadorGru] PRIMARY KEY CLUSTERED ([codsistema], [codprestamo]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsCNBVIdentificadorGru] TO [rie_jaguilar]
GO

GRANT SELECT ON [dbo].[tCsCNBVIdentificadorGru] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsCNBVIdentificadorGru] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsCNBVIdentificadorGru] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsCNBVIdentificadorGru] TO [rie_blozanob]
GO