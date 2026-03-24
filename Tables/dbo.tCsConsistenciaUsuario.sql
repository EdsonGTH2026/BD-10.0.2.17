CREATE TABLE [dbo].[tCsConsistenciaUsuario] (
  [Tabla] [varchar](50) NOT NULL,
  [Campo] [varchar](50) NOT NULL,
  [CambiaCodigo] [bit] NULL,
  [Consolidado] [bit] NULL,
  [CampoFecha] [bit] NULL,
  [Existe] [bit] NULL,
  [Consolida] [bit] NULL,
  CONSTRAINT [PK_tCsConsistenciaUsuario] PRIMARY KEY CLUSTERED ([Tabla], [Campo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsConsistenciaUsuario_Tipo]
  ON [dbo].[tCsConsistenciaUsuario] ([Consolidado], [Existe], [Tabla])
  ON [PRIMARY]
GO