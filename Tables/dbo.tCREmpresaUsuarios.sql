CREATE TABLE [dbo].[tCREmpresaUsuarios] (
  [Empresa] [varchar](2) NOT NULL,
  [ClaveOtorgante] [varchar](50) NOT NULL,
  [CodUsuario] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  [Asignado] [varchar](100) NULL,
  [Contraseña] [varchar](50) NULL,
  [Expira] [smalldatetime] NULL,
  [Consulta] [smalldatetime] NULL,
  [Estado] [varchar](25) NULL,
  [EnviaCorreo] [bit] NULL,
  CONSTRAINT [PK_tCREmpresaUsuarios] PRIMARY KEY CLUSTERED ([Empresa], [ClaveOtorgante])
)
ON [PRIMARY]
GO