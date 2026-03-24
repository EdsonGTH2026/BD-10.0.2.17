CREATE TABLE [dbo].[tINTFArchivo] (
  [Periodo] [varchar](6) NOT NULL,
  [Cadena] [text] NULL,
  CONSTRAINT [PK_tINTFArchivo] PRIMARY KEY CLUSTERED ([Periodo])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO