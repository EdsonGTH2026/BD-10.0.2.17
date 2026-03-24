CREATE TABLE [dbo].[tCsXaNotificacionUsuario] (
  [CodUsuario] [varchar](20) NOT NULL,
  [IdNotificacion] [int] NOT NULL,
  [VigenciaInicial] [smalldatetime] NOT NULL,
  [VigenciaFinal] [smalldatetime] NOT NULL,
  [Activo] [smallint] NOT NULL,
  [FechaAlta] [datetime] NOT NULL,
  [CodUsAlta] [varchar](20) NOT NULL,
  [FechaModificacion] [datetime] NOT NULL,
  [CodUsModificacion] [varchar](20) NOT NULL,
  CONSTRAINT [PK_tCsXaNotificacionUsuario] PRIMARY KEY CLUSTERED ([CodUsuario], [IdNotificacion])
)
ON [PRIMARY]
GO