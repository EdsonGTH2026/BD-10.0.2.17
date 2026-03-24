CREATE TABLE [dbo].[tCsClientesTipo] (
  [Tipo] [varchar](50) NOT NULL,
  [Identificador] [varchar](2) NULL,
  [Descripcion] [varchar](200) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsClientesTipo] PRIMARY KEY CLUSTERED ([Tipo])
)
ON [PRIMARY]
GO