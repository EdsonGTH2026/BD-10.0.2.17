CREATE TABLE [dbo].[tSgClTipoObjeto] (
  [TipoObj] [int] NOT NULL,
  [Nombre] [varchar](30) COLLATE Modern_Spanish_CI_AS NULL,
  [Descripcion] [varchar](50) COLLATE Modern_Spanish_CI_AS NULL,
  CONSTRAINT [PK_tSTipoObjeto] PRIMARY KEY CLUSTERED ([TipoObj])
)
ON [PRIMARY]
GO