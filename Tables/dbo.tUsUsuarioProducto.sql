CREATE TABLE [dbo].[tUsUsuarioProducto] (
  [IdUsSistProd] [int] IDENTITY,
  [CodUsuario] [char](15) NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [CodProducto] [varchar](4) NULL,
  [DatosCompletos] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioProducto_DatosCompletos] DEFAULT (0),
  CONSTRAINT [PK_tUsUsuarioProducto] PRIMARY KEY CLUSTERED ([IdUsSistProd])
)
ON [PRIMARY]
GO