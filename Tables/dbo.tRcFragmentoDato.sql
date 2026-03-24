CREATE TABLE [dbo].[tRcFragmentoDato] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Representa] [varchar](50) NOT NULL,
  [Campo] [varchar](50) NOT NULL,
  [Dato] [varchar](400) NULL,
  CONSTRAINT [PK_tRcFragmentoDato] PRIMARY KEY CLUSTERED ([Periodo], [Fila], [Representa], [Campo])
)
ON [PRIMARY]
GO