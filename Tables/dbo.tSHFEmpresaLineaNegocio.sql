CREATE TABLE [dbo].[tSHFEmpresaLineaNegocio] (
  [Empresa] [varchar](50) NOT NULL,
  [LineaNegocio] [int] NOT NULL,
  CONSTRAINT [PK_tSHFEmpresaLineaNegocio] PRIMARY KEY CLUSTERED ([Empresa], [LineaNegocio])
)
ON [PRIMARY]
GO