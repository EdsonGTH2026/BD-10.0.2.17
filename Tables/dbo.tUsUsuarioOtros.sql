CREATE TABLE [dbo].[tUsUsuarioOtros] (
  [CodUsuario] [char](15) NOT NULL,
  [IdUsOtroDato] [int] NOT NULL,
  [Dato] [varchar](150) NULL,
  CONSTRAINT [PK_tUsUsuarioOtros] PRIMARY KEY CLUSTERED ([CodUsuario], [IdUsOtroDato])
)
ON [PRIMARY]
GO