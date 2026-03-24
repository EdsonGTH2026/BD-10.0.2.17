CREATE TABLE [dbo].[tCsFondReportados] (
  [CodFondo] [varchar](2) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Codprestamo] [varchar](25) NOT NULL,
  [Codusuario] [varchar](15) NOT NULL,
  [Dato1Fec] [smalldatetime] NULL,
  [Dato1Cad] [varchar](5) NULL,
  [Dato2Cad] [varchar](15) NULL,
  [Dato3Cad] [varchar](50) NULL,
  CONSTRAINT [PK_tCsFondReportados] PRIMARY KEY CLUSTERED ([CodFondo], [Fecha], [Codprestamo], [Codusuario])
)
ON [PRIMARY]
GO