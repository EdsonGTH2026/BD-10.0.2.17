CREATE TABLE [dbo].[tCsCaCredReestrucPagSostenido] (
  [Id] [int] IDENTITY,
  [CodPrestamo] [varchar](20) NOT NULL,
  [Estado] [varchar](10) NOT NULL,
  [FechaRegistro] [smalldatetime] NOT NULL,
  [Activo] [bit] NOT NULL,
  CONSTRAINT [PK_tCsCaCredReestrucPagSostenido] PRIMARY KEY CLUSTERED ([Id])
)
ON [PRIMARY]
GO