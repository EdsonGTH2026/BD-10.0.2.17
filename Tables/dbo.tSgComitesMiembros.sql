CREATE TABLE [dbo].[tSgComitesMiembros] (
  [CodComite] [char](5) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [codoficina] [varchar](15) NULL,
  CONSTRAINT [PK_TSgAutoComiteUs] PRIMARY KEY CLUSTERED ([CodComite], [CodUsuario])
)
ON [PRIMARY]
GO