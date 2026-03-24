CREATE TABLE [dbo].[tCRUsuarios] (
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [Cargo] [varchar](50) NULL,
  [Correo] [varchar](50) NULL,
  [CopiaCorreo] [varchar](50) NULL,
  CONSTRAINT [PK_tCRUsuarios] PRIMARY KEY CLUSTERED ([CodUsuario])
)
ON [PRIMARY]
GO