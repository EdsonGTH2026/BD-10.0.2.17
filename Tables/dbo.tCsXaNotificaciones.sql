CREATE TABLE [dbo].[tCsXaNotificaciones] (
  [IdNotificacion] [int] IDENTITY,
  [Descripcion] [varchar](50) NOT NULL,
  [Texto1] [varchar](100) NOT NULL,
  [Texto2] [varchar](100) NOT NULL,
  [VigenciaInicial] [smalldatetime] NOT NULL,
  [VigenciaFinal] [smalldatetime] NOT NULL,
  [NombreArchivo] [varchar](30) NOT NULL,
  [Ruta] [varchar](200) NOT NULL,
  [RutaWeb] [varchar](200) NOT NULL,
  [IdNotificacionTipo] [int] NOT NULL,
  [Predeterminada] [smallint] NOT NULL,
  [Activo] [smallint] NOT NULL,
  [FechaAlta] [datetime] NOT NULL,
  [CodUsAlta] [varchar](20) NOT NULL,
  [FechaModificacion] [datetime] NOT NULL,
  [CodUsModificacion] [varchar](20) NOT NULL,
  CONSTRAINT [PK_tCsXaNotificaciones] PRIMARY KEY CLUSTERED ([IdNotificacion])
)
ON [PRIMARY]
GO