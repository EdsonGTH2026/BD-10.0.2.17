CREATE TABLE [dbo].[tCsFondAsumidos] (
  [CodFondo] [varchar](2) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Codprestamo] [varchar](25) NOT NULL,
  [Codusuario] [varchar](15) NOT NULL,
  [Porque] [varchar](100) NULL,
  CONSTRAINT [PK_tCsFondAsumidos] PRIMARY KEY CLUSTERED ([CodFondo], [Fecha], [Codprestamo], [Codusuario])
)
ON [PRIMARY]
GO