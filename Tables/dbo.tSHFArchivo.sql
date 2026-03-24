CREATE TABLE [dbo].[tSHFArchivo] (
  [Periodo] [varchar](6) NOT NULL,
  [Concepto] [varchar](50) NOT NULL,
  [Cadena] [text] NULL,
  CONSTRAINT [PK_tSHFArchivo] PRIMARY KEY CLUSTERED ([Periodo], [Concepto])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO