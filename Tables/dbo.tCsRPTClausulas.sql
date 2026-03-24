CREATE TABLE [dbo].[tCsRPTClausulas] (
  [Tipo] [varchar](50) NOT NULL,
  [Titulo] [varchar](50) NOT NULL,
  [Orden] [int] NULL,
  [Texto1] [varchar](900) NULL,
  [Texto2] [varchar](900) NULL,
  [Condicion] [varchar](100) NULL,
  [DAdicional] [varchar](50) NULL,
  [TAdicional] [varchar](900) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsRPTClausulas] PRIMARY KEY CLUSTERED ([Tipo], [Titulo])
)
ON [PRIMARY]
GO