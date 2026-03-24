CREATE TABLE [dbo].[tCaClCobrTipoDoc] (
  [CodDocumento] [smallint] NOT NULL,
  [DescDocumento] [varchar](50) NULL,
  [Ruta] [varchar](250) NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL
)
ON [PRIMARY]
GO