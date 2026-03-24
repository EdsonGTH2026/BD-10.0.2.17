CREATE TABLE [dbo].[tCaClCheckListGrupo] (
  [Grupo] [varchar](3) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCaClCheckListGrupo] PRIMARY KEY CLUSTERED ([Grupo])
)
ON [PRIMARY]
GO