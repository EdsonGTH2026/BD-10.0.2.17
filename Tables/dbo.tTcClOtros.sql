CREATE TABLE [dbo].[tTcClOtros] (
  [CodOtros] [char](5) NOT NULL,
  [Descripcion] [varchar](30) NULL,
  [ContaCodigo] [varchar](25) NOT NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NULL
)
ON [PRIMARY]
GO