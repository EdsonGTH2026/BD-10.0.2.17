CREATE TABLE [dbo].[tCaClCaracteristicas] (
  [CodCarac] [tinyint] NOT NULL,
  [descripcion] [varchar](50) NOT NULL,
  [activo] [bit] NOT NULL,
  [orden] [tinyint] NULL,
  [Devenga] [bit] NULL,
  CONSTRAINT [PK_tCaClCaracteristicas] PRIMARY KEY CLUSTERED ([CodCarac])
)
ON [PRIMARY]
GO