CREATE TABLE [dbo].[tSgAcciones] (
  [CodSistema] [char](2) NOT NULL,
  [CodGrupo] [varchar](6) NOT NULL,
  [Opcion] [varchar](10) NOT NULL,
  [Acceder] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Acceder] DEFAULT (1),
  [Anadir] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Anadir] DEFAULT (1),
  [Editar] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Editar] DEFAULT (1),
  [Grabar] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Grabar] DEFAULT (1),
  [Cancelar] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Cancelar] DEFAULT (1),
  [Eliminar] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Eliminar] DEFAULT (1),
  [Imprimir] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Imprimir] DEFAULT (1),
  [Cerrar] [bit] NOT NULL CONSTRAINT [DF_tSgAcciones_Cerrar] DEFAULT (1),
  CONSTRAINT [PK_tSgAcciones] PRIMARY KEY CLUSTERED ([CodSistema], [CodGrupo], [Opcion])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tSgAcciones] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgAcciones_tSgGrupos] FOREIGN KEY ([CodGrupo]) REFERENCES [dbo].[tSgGrupos] ([CodGrupo]) ON DELETE CASCADE ON UPDATE CASCADE
GO

ALTER TABLE [dbo].[tSgAcciones] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgAcciones_tSgMenus] FOREIGN KEY ([CodSistema], [Opcion]) REFERENCES [dbo].[tSgOptions] ([CodSistema], [Opcion]) ON DELETE CASCADE ON UPDATE CASCADE
GO