CREATE TABLE [dbo].[tCsUDIS] (
  [Fecha] [smalldatetime] NOT NULL,
  [UDI] [decimal](18, 8) NULL,
  [SelloElectronico] [varchar](100) NULL,
  CONSTRAINT [PK_tCsUDIS] PRIMARY KEY CLUSTERED ([Fecha])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsUDIS] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsUDIS] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsUDIS] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsUDIS] TO [rie_blozanob]
GO