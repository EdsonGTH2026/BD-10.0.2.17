CREATE TABLE [dbo].[tCaGrupoClieEstados] (
  [CodGrupo] [char](15) NOT NULL,
  [CodCliente] [char](15) NOT NULL,
  [FechaEstado] [smalldatetime] NOT NULL,
  [EstadoCliente] [varchar](10) NULL,
  CONSTRAINT [PK_tCaGrupoClieEstados] PRIMARY KEY CLUSTERED ([CodGrupo], [CodCliente], [FechaEstado])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaGrupoClieEstados] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaGrupoClieEstados_tCaGrupos] FOREIGN KEY ([CodGrupo]) REFERENCES [dbo].[tCaGrupos] ([CodGrupo])
GO

ALTER TABLE [dbo].[tCaGrupoClieEstados] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaGrupoClieEstados_tUsUsuarios] FOREIGN KEY ([CodCliente]) REFERENCES [dbo].[tUsUsuarios] ([CodUsuario])
GO