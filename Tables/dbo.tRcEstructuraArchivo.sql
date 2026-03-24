CREATE TABLE [dbo].[tRcEstructuraArchivo] (
  [EstructuraArchivo] [varchar](2) NOT NULL,
  [Segmento] [varchar](100) NULL,
  [IdentificadorInicio] [varchar](10) NULL,
  CONSTRAINT [PK_tRcEstructuraArchivo] PRIMARY KEY CLUSTERED ([EstructuraArchivo])
)
ON [PRIMARY]
GO