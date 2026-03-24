CREATE TABLE [dbo].[tCsLogCambioCodigo] (
  [Anterior] [varchar](25) NOT NULL,
  [Nuevo] [varchar](25) NOT NULL,
  [Fecha] [datetime] NOT NULL,
  [Tabla] [varchar](50) NOT NULL,
  [Columna] [varchar](50) NOT NULL,
  [Duracion] [int] NULL,
  [Afectadas] [int] NULL,
  CONSTRAINT [PK_tCsLogCambioCodigo] PRIMARY KEY CLUSTERED ([Anterior], [Nuevo], [Fecha], [Tabla], [Columna])
)
ON [PRIMARY]
GO