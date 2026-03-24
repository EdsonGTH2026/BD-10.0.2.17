CREATE TABLE [dbo].[tCsClPrioridad] (
  [Prioridad] [int] NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Activo] [nchar](10) NULL,
  CONSTRAINT [PK_tCsClPrioridad] PRIMARY KEY CLUSTERED ([Prioridad])
)
ON [PRIMARY]
GO