CREATE TABLE [dbo].[tSgUsuarios] (
  [Usuario] [varchar](20) NOT NULL,
  [CodUsuario] [char](15) NULL,
  [NombreCompleto] [varchar](100) NULL,
  [Descripcion] [text] NULL,
  [Contrasena] [varchar](100) NOT NULL CONSTRAINT [DF_tSgUsuarios_Contrasena] DEFAULT (''),
  [FechaAlta] [smalldatetime] NULL,
  [FechaVigencia] [smalldatetime] NULL,
  [CambiaContrasena] [bit] NOT NULL CONSTRAINT [DF_tSgUsuarios_CambiaContrasena] DEFAULT (1),
  [RenuevaVigencia] [bit] NOT NULL CONSTRAINT [DF_tSgUsuarios_RenuevaVigencia] DEFAULT (1),
  [Activo] [bit] NULL CONSTRAINT [DF_tSgUsuarios_Activo] DEFAULT (1),
  [CodOficina] [varchar](4) NULL,
  [TodasOficinas] [bit] NULL CONSTRAINT [DF_tSgUsuarios_TodasOficinas] DEFAULT (0),
  [PerfilRegistrado] [varchar](50) NULL,
  CONSTRAINT [PK_tSgUsuarios] PRIMARY KEY CLUSTERED ([Usuario])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE INDEX [IX_tSgUsuarios_CodUsuario_Activo_FechaVigencia]
  ON [dbo].[tSgUsuarios] ([CodUsuario], [Activo], [FechaVigencia])
  ON [PRIMARY]
GO