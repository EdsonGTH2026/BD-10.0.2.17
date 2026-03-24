CREATE TABLE [dbo].[tCsUsuarios] (
  [CodOficina] [varchar](4) NOT NULL,
  [Usuario] [varchar](20) NOT NULL,
  [CodUsuario] [char](15) NULL,
  [NombreCompleto] [varchar](80) NULL,
  [Descripcion] [varchar](80) NULL,
  [CodIdioma] [varchar](7) NOT NULL,
  [FechaAlta] [smalldatetime] NULL,
  [FechaVigencia] [smalldatetime] NULL,
  [CambiaContrasena] [bit] NOT NULL CONSTRAINT [DF_tCsUsuarios_CambiaContrasena] DEFAULT (1),
  [RenuevaVigencia] [bit] NOT NULL CONSTRAINT [DF_tCsUsuarios_RenuevaVigencia] DEFAULT (1),
  [Activo] [bit] NULL CONSTRAINT [DF_tCsUsuarios_Activo] DEFAULT (1),
  CONSTRAINT [PK_tCsUsuarios] PRIMARY KEY CLUSTERED ([CodOficina], [Usuario])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tabla de Usuarios que acceden al sistema', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Usuario que es el mismo login de SQL Server', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'Usuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del usuario en tUsUsuarios', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre completo del usuario', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'NombreCompleto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El trabajo que realizará como usuario del sistema', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'Descripcion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del idioma que utilizara en Finmas (nombre de tabla relacionada???)', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'CodIdioma'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de registro del usuario en el sistema', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'FechaAlta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha hasta la cual el usuario puede acceder al sistema', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'FechaVigencia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1: se permite cambiar contraseña al usuario, 0:no se permite', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'CambiaContrasena'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1: se permite renovar la vigencia del usuario, 0:no se permite', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'RenuevaVigencia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1:Activo, 0:Inactivo', 'SCHEMA', N'dbo', 'TABLE', N'tCsUsuarios', 'COLUMN', N'Activo'
GO