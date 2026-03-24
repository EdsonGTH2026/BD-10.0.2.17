CREATE TABLE [dbo].[tCaDespachoUsuario] (
  [IdDespacho] [int] NOT NULL,
  [Usuario] [varchar](20) NOT NULL,
  [Activo] [tinyint] NOT NULL,
  CONSTRAINT [PK_tCaDespachoUsuario] PRIMARY KEY CLUSTERED ([IdDespacho], [Usuario])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaDespachoUsuario] TO [jmartinezc]
GO

GRANT SELECT ON [dbo].[tCaDespachoUsuario] TO [jarriagaa]
GO

ALTER TABLE [dbo].[tCaDespachoUsuario]
  ADD CONSTRAINT [FK_tCaDespachoUsuario_tCaClDespacho] FOREIGN KEY ([IdDespacho]) REFERENCES [dbo].[tCaClDespacho] ([IdDespacho])
GO