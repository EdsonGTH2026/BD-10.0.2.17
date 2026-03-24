CREATE TABLE [dbo].[tSATTipoArchivo] (
  [Tipo] [varchar](2) NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [Respuesta] [varchar](2) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tSATTipoArchivo] PRIMARY KEY CLUSTERED ([Tipo])
)
ON [PRIMARY]
GO