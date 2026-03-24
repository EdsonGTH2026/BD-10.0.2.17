CREATE TABLE [dbo].[tClUbigeoEquivalencias] (
  [Antiguo] [varchar](10) NOT NULL,
  [Actual] [varchar](10) NOT NULL,
  [Registro] [smalldatetime] NULL,
  CONSTRAINT [PK_tClUbigeoEquivalencias] PRIMARY KEY CLUSTERED ([Antiguo], [Actual])
)
ON [PRIMARY]
GO