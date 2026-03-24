CREATE TABLE [dbo].[tClOficinasDeptos] (
  [CodDepto] [varchar](5) NOT NULL,
  [CodOficinaTipo] [varchar](5) NULL,
  [Descripcion] [varchar](100) NULL,
  [Orden] [tinyint] NULL,
  [Activa] [bit] NOT NULL,
  [CodCargoArea] [varchar](6) NOT NULL
)
ON [PRIMARY]
GO