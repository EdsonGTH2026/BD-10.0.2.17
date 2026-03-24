CREATE TABLE [dbo].[tTaCuentasUsuarios] (
  [codusuario] [varchar](20) NOT NULL,
  [nombreusuario] [varchar](200) NULL,
  [codoficina] [varchar](4) NULL,
  [estado] [bit] NULL CONSTRAINT [DF_tTaCuentasUsuarios_estado] DEFAULT (1),
  [fechareg] [smalldatetime] NULL,
  [perfil] [varchar](10) NULL,
  CONSTRAINT [PK_tTaCuentasUsuarios] PRIMARY KEY CLUSTERED ([codusuario])
)
ON [PRIMARY]
GO