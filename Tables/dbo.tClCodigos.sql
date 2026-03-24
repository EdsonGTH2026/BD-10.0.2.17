CREATE TABLE [dbo].[tClCodigos] (
  [CodSistema] [char](2) NOT NULL,
  [NombreCodigo] [varchar](20) NOT NULL,
  [Modulo] [tinyint] NULL,
  [Longitud] [tinyint] NULL,
  [Inicio] [int] NULL,
  [Final] [int] NULL,
  [Actual] [int] NULL,
  [ConGuion] [bit] NULL,
  [Guion] [char](1) NULL,
  [CodOficina] [varchar](4) NOT NULL
)
ON [PRIMARY]
GO