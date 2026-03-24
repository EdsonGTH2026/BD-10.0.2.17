CREATE TABLE [dbo].[tCaClMotivos] (
  [CodMotivo] [smallint] NOT NULL,
  [DescMotivo] [varchar](200) NOT NULL,
  [TipoMotivo] [tinyint] NOT NULL,
  [Orden] [tinyint] NOT NULL,
  [Activo] [bit] NOT NULL,
  [ContaCodigo] [varchar](5) NOT NULL,
  [SeContabiliza] [bit] NOT NULL
)
ON [PRIMARY]
GO