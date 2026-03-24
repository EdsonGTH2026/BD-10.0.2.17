CREATE TABLE [dbo].[tSgConfigGeneral] (
  [IdConfigGeneral] [int] IDENTITY,
  [Sistema] [varchar](3) NOT NULL,
  [CodOficina] [varchar](3) NOT NULL,
  [Tipo] [varchar](20) NOT NULL,
  [Valor] [varchar](50) NOT NULL,
  [Descripcion] [varchar](100) NOT NULL,
  [Activo] [tinyint] NOT NULL,
  CONSTRAINT [PK_tsgConfigGeneral] PRIMARY KEY CLUSTERED ([IdConfigGeneral])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tSgConfigGeneral]
  ON [dbo].[tSgConfigGeneral] ([Sistema], [CodOficina], [Tipo])
  ON [PRIMARY]
GO