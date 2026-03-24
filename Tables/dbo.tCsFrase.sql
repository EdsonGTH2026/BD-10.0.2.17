CREATE TABLE [dbo].[tCsFrase] (
  [Secuencial] [int] NOT NULL,
  [Fecha] [smalldatetime] NULL,
  [Frase] [text] NULL,
  [Autor] [varchar](50) NULL,
  [Aleatorio] [int] NULL,
  [Veces] [int] NULL,
  CONSTRAINT [PK_tCsFrase] PRIMARY KEY CLUSTERED ([Secuencial])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO