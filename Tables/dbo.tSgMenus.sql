CREATE TABLE [dbo].[tSgMenus] (
  [CodArbolOpcion] [varchar](30) NOT NULL,
  [DescOpcion] [varchar](200) NOT NULL,
  [descOpcionIdioma2] [varchar](200) NOT NULL,
  [Activo] [bit] NOT NULL CONSTRAINT [DF_tSgMenus_Activo1] DEFAULT (1),
  CONSTRAINT [PK_tSgMenus1] PRIMARY KEY CLUSTERED ([CodArbolOpcion])
)
ON [PRIMARY]
GO