CREATE TABLE [dbo].[tCsClMonedas] (
  [CodMoneda] [tinyint] NOT NULL,
  [DescAbreviada] [varchar](10) NULL,
  CONSTRAINT [PK_tCsClMonedas] PRIMARY KEY CLUSTERED ([CodMoneda])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de la moneda', 'SCHEMA', N'dbo', 'TABLE', N'tCsClMonedas', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripcion abreviada de la moneda', 'SCHEMA', N'dbo', 'TABLE', N'tCsClMonedas', 'COLUMN', N'DescAbreviada'
GO