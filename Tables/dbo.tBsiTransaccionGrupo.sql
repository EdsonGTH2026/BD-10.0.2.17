CREATE TABLE [dbo].[tBsiTransaccionGrupo] (
  [CodigoGrupo] [varchar](8) NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [Registro] [datetime] NOT NULL,
  CONSTRAINT [PK_tBsiGrupoTransaccion] PRIMARY KEY CLUSTERED ([CodigoGrupo])
)
ON [PRIMARY]
GO