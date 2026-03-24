CREATE TABLE [dbo].[tCaClDespacho] (
  [IdDespacho] [int] NOT NULL,
  [Nombre] [varchar](80) NULL,
  [FechaAlta] [smalldatetime] NULL,
  [FechaModificacion] [smalldatetime] NULL,
  [Activo] [tinyint] NOT NULL,
  CONSTRAINT [PK_tCaClDespacho] PRIMARY KEY CLUSTERED ([IdDespacho])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaClDespacho] TO [jmartinezc]
GO

GRANT SELECT ON [dbo].[tCaClDespacho] TO [jarriagaa]
GO