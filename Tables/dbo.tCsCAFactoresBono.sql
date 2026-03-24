CREATE TABLE [dbo].[tCsCAFactoresBono] (
  [CodFactor] [int] NOT NULL,
  [Item] [int] NOT NULL,
  [PorAnaliza] [decimal](10, 2) NULL,
  [PorFactor] [decimal](10, 4) NULL,
  [TipoFactor] [int] NULL,
  [RangoFactor] [varchar](5) NULL,
  [Rango2Factor] [varchar](5) NULL,
  CONSTRAINT [PK_tCsCAFactoresBono] PRIMARY KEY CLUSTERED ([CodFactor], [Item])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1: porcentaje 2:constante', 'SCHEMA', N'dbo', 'TABLE', N'tCsCAFactoresBono', 'COLUMN', N'TipoFactor'
GO