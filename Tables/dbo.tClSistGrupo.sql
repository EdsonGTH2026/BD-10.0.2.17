CREATE TABLE [dbo].[tClSistGrupo] (
  [CodSistema] [char](2) NOT NULL,
  [CodGrupoOficina] [tinyint] NOT NULL,
  [Descripcion] [varchar](100) NOT NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [tinyint] NULL
)
ON [PRIMARY]
GO