CREATE TABLE [dbo].[tCsClPuestos] (
  [Codigo] [int] NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [Clave] [char](3) NULL,
  [Nivel] [int] NULL,
  [Estado] [char](1) NULL CONSTRAINT [DF_tCsClPuestos_Estado] DEFAULT (1),
  [EsNomina] [char](1) NULL CONSTRAINT [DF_tCsClPuestos_EsNomina] DEFAULT (1),
  [CtrolRegistro] [bit] NULL CONSTRAINT [DF_tCsClPuestos_CtrolRegistro] DEFAULT (1),
  [FiltraCreditos] [bit] NULL,
  [idArea] [int] NULL,
  CONSTRAINT [PK_tCsClPuestos] PRIMARY KEY CLUSTERED ([Codigo])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsClPuestos] TO [rie_jalvarezc]
GO