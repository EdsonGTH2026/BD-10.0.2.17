CREATE TABLE [dbo].[tCsClParentesco] (
  [CodParentesco] [int] NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [Atlas] [int] NULL,
  [Importancia] [int] NULL,
  [Estado] [char](1) NULL CONSTRAINT [DF_tCsClParentesco_estado] DEFAULT (1),
  CONSTRAINT [PK_tCsClParentesco] PRIMARY KEY CLUSTERED ([CodParentesco])
)
ON [PRIMARY]
GO