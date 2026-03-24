CREATE TABLE [dbo].[tCsHomonimia] (
  [CodUsuario] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [Homonimo] [varchar](25) NOT NULL,
  [NombreCompleto] [varchar](200) NULL,
  [Interna] [bit] NULL,
  [Externa] [bit] NULL,
  CONSTRAINT [PK_tCsHomonimia] PRIMARY KEY CLUSTERED ([CodUsuario], [Homonimo])
)
ON [PRIMARY]
GO