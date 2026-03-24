CREATE TABLE [dbo].[tSgGrupos] (
  [CodGrupo] [varchar](6) NOT NULL,
  [Grupo] [varchar](50) NULL,
  [Descripcion] [varchar](50) NULL,
  [FechaReg] [smalldatetime] NULL CONSTRAINT [DF_tSgGrupos_FechaReg] DEFAULT (getdate()),
  [Activo] [bit] NULL CONSTRAINT [DF_tSgGrupos_Activo] DEFAULT (1),
  [FechaInactivo] [smalldatetime] NULL,
  [Perfil] [varchar](10) NULL,
  CONSTRAINT [PK_tSgGrupos] PRIMARY KEY CLUSTERED ([CodGrupo])
)
ON [PRIMARY]
GO