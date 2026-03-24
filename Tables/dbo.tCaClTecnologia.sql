CREATE TABLE [dbo].[tCaClTecnologia] (
  [Tecnologia] [char](1) NOT NULL,
  [NombreTec] [varchar](50) NULL,
  [Rubro] [varchar](50) NULL,
  [BuroCredito] [varchar](10) NULL,
  [Responsabilidad] [varchar](50) NULL,
  [Pronafim] [char](1) NULL,
  [Veridico] [varchar](50) NULL,
  CONSTRAINT [PK_tCaClTecnologia] PRIMARY KEY CLUSTERED ([Tecnologia])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Depende de la Tabla 2 del INTF', 'SCHEMA', N'dbo', 'TABLE', N'tCaClTecnologia', 'COLUMN', N'Responsabilidad'
GO