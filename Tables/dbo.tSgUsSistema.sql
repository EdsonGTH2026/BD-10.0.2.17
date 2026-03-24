CREATE TABLE [dbo].[tSgUsSistema] (
  [Usuario] [varchar](20) NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [CodGrupo] [varchar](6) NULL,
  [FechaReg] [smalldatetime] NULL,
  [PorDefecto] [bit] NOT NULL CONSTRAINT [DF_tSgUsSistema_PorDefecto] DEFAULT (0),
  [Activo] [bit] NOT NULL CONSTRAINT [DF_tSgUsSistema_Activo] DEFAULT (1),
  CONSTRAINT [PK_tSgUsuariosSistema] PRIMARY KEY CLUSTERED ([Usuario], [CodSistema])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tSgUsSistema] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgUsSistema_tSgGrupos] FOREIGN KEY ([CodGrupo]) REFERENCES [dbo].[tSgGrupos] ([CodGrupo]) ON DELETE CASCADE ON UPDATE CASCADE
GO