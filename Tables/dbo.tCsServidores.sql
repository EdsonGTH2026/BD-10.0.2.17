CREATE TABLE [dbo].[tCsServidores] (
  [IdServidor] [int] NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [NombreIP] [varchar](50) NULL,
  [NombreBD] [varchar](50) NULL,
  [Tipo] [char](1) NULL,
  [IdTextual] [varchar](50) NULL,
  [NombreServidor] [varchar](100) NULL,
  [Registro] [datetime] NULL,
  CONSTRAINT [PK_tCsServidores] PRIMARY KEY CLUSTERED ([IdServidor])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsServidores] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsServidores] TO [Int_dreyesg]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1: Operativo, 2: Contable, 3: Consolidada', 'SCHEMA', N'dbo', 'TABLE', N'tCsServidores', 'COLUMN', N'Tipo'
GO