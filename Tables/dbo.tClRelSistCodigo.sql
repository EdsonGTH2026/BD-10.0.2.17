CREATE TABLE [dbo].[tClRelSistCodigo] (
  [CodSistema] [char](2) NOT NULL,
  [NombreCodigo] [varchar](20) NOT NULL,
  [Campo] [varchar](20) NOT NULL,
  [Longitud] [tinyint] NULL,
  [Orden] [tinyint] NULL,
  [Relleno] [char](1) NULL,
  [TipoCampo] [tinyint] NULL,
  [CodOficina] [varchar](4) NOT NULL
)
ON [PRIMARY]
GO