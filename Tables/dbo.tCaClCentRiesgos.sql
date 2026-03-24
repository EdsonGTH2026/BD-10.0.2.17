CREATE TABLE [dbo].[tCaClCentRiesgos] (
  [CodCentRiesgos] [varchar](10) NOT NULL,
  [Descripcion] [varchar](100) NOT NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [tinyint] NOT NULL,
  [Tipo] [char](2) NULL
)
ON [PRIMARY]
GO