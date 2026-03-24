CREATE TABLE [dbo].[tCsPdnServidor] (
  [Servidor] [varchar](50) NOT NULL,
  [Incorrecto] [int] NULL,
  [Registro] [datetime] NULL,
  CONSTRAINT [PK_tCsPdnServidor] PRIMARY KEY CLUSTERED ([Servidor])
)
ON [PRIMARY]
GO