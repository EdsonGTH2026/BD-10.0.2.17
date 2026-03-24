CREATE TABLE [dbo].[tCsPrNivel] (
  [Nivel] [varchar](30) NOT NULL,
  [Ahorro] [varchar](30) NULL,
  [Cartera] [varchar](30) NULL,
  [Descripcion] [varchar](100) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsPrNivel] PRIMARY KEY CLUSTERED ([Nivel])
)
ON [PRIMARY]
GO