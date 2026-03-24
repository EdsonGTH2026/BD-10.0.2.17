CREATE TABLE [dbo].[tCsXaClNotificacionTipo] (
  [IdNotificacionTipo] [int] NOT NULL,
  [Descripcion] [varchar](50) NOT NULL,
  [Activo] [smallint] NOT NULL,
  [FechaAlta] [datetime] NOT NULL,
  [CodUsAlta] [varchar](20) NOT NULL,
  CONSTRAINT [PK_tCsXaClNotificacionTipo] PRIMARY KEY CLUSTERED ([IdNotificacionTipo])
)
ON [PRIMARY]
GO