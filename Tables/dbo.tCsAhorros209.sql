CREATE TABLE [dbo].[tCsAhorros209] (
  [fecha] [smalldatetime] NOT NULL,
  [codcuenta] [varchar](25) NOT NULL,
  [renovado] [int] NOT NULL,
  [saldofinal] [money] NULL,
  CONSTRAINT [PK_tCsAhorros209] PRIMARY KEY CLUSTERED ([fecha], [codcuenta], [renovado])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsAhorros209] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsAhorros209] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsAhorros209] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsAhorros209] TO [rie_blozanob]
GO