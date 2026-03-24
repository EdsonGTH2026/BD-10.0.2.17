CREATE TABLE [dbo].[tCsFirmaDocumentos] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodSistema] [varchar](2) NOT NULL,
  [Cuenta] [varchar](50) NOT NULL,
  [Tipo] [varchar](50) NOT NULL,
  [Firma] [varchar](100) NULL,
  CONSTRAINT [PK_tCsFirmaDocumentos] PRIMARY KEY CLUSTERED ([CodOficina], [CodSistema], [Cuenta], [Tipo])
)
ON [PRIMARY]
GO