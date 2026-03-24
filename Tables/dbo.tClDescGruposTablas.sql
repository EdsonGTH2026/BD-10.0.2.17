CREATE TABLE [dbo].[tClDescGruposTablas] (
  [Tabla] [varchar](20) NOT NULL,
  [Grupo] [tinyint] NOT NULL,
  [Nombre] [varchar](20) NULL,
  CONSTRAINT [PK_tClDescGruposTablas] PRIMARY KEY CLUSTERED ([Tabla], [Grupo])
)
ON [PRIMARY]
GO