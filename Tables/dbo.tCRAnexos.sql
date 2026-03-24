CREATE TABLE [dbo].[tCRAnexos] (
  [Empresa] [char](10) NOT NULL,
  [Anexo] [char](1) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [Representante] [varchar](15) NOT NULL,
  [Matriz] [varchar](4) NOT NULL,
  [Registro] [smalldatetime] NOT NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCR] PRIMARY KEY CLUSTERED ([Empresa], [Anexo], [CodUsuario], [Representante], [Matriz], [Registro])
)
ON [PRIMARY]
GO