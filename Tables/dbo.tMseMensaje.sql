CREATE TABLE [dbo].[tMseMensaje] (
  [Ubicacion] [varchar](50) NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [Fin] [smalldatetime] NOT NULL,
  [Registro] [datetime] NULL,
  [Puntaje] [decimal](18, 4) NULL,
  [Mensaje] [varchar](1000) NULL,
  CONSTRAINT [PK_tMseMensaje] PRIMARY KEY CLUSTERED ([Ubicacion], [Inicio], [Fin])
)
ON [PRIMARY]
GO