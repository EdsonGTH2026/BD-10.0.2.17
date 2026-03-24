CREATE TABLE [dbo].[tCsPadronTablasColumnas] (
  [Tabla] [varchar](50) NOT NULL,
  [Columna] [varchar](128) NOT NULL,
  [Caption] [varchar](1000) NULL,
  [TipoDato] [int] NULL,
  [TipoNombre] [varchar](50) NULL,
  [Presicion] [int] NULL,
  [Tamaño] [int] NULL,
  [Escala] [int] NULL,
  [Nulo] [bit] NULL,
  [PosicionOrdinal] [int] NULL,
  CONSTRAINT [PK_tCsPadronTablasColumnas] PRIMARY KEY CLUSTERED ([Tabla], [Columna])
)
ON [PRIMARY]
GO