CREATE TABLE [dbo].[tCAClTipoPlaz] (
  [CodTipoPlaz] [char](1) NOT NULL,
  [DescTipoPlaz] [varchar](15) NULL,
  [DiaTipoPlaz] [smallint] NULL,
  [FechFija] [bit] NOT NULL CONSTRAINT [DF_tCAClTipoPlaz_FechFija] DEFAULT (0),
  [EstTipoPlaz] [varchar](3) NULL,
  [EstLinea] [bit] NOT NULL CONSTRAINT [DF_tCAClTipoPlaz_EstLinea] DEFAULT (1),
  [Plural] [varchar](50) NULL,
  CONSTRAINT [PK_tCAClTipoPlaz] PRIMARY KEY CLUSTERED ([CodTipoPlaz])
)
ON [PRIMARY]
GO