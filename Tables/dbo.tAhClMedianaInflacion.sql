CREATE TABLE [dbo].[tAhClMedianaInflacion] (
  [IdMediana] [int] NOT NULL,
  [FechaPublicacion] [datetime] NOT NULL,
  [MedianaInflacion] [money] NOT NULL,
  [FechaAlta] [datetime] NULL,
  [UsuarioAlta] [varchar](15) NULL,
  [Activo] [bit] NOT NULL
)
ON [PRIMARY]
GO