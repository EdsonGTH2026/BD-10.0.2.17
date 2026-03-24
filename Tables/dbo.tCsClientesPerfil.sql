CREATE TABLE [dbo].[tCsClientesPerfil] (
  [Perfil] [varchar](14) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](200) NULL,
  CONSTRAINT [PK_tCsClientesPerfil] PRIMARY KEY CLUSTERED ([Perfil])
)
ON [PRIMARY]
GO