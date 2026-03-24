CREATE TABLE [dbo].[tSgRegClInc] (
  [CodInc] [int] NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [idArea] [int] NULL,
  CONSTRAINT [PK_tSgRegClInc] PRIMARY KEY CLUSTERED ([CodInc])
)
ON [PRIMARY]
GO