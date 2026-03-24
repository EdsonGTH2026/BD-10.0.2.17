CREATE TABLE [dbo].[tCsCierresBackup] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [BackupC] [bit] NULL,
  [Inicio] [datetime] NULL,
  [Fin] [datetime] NULL,
  CONSTRAINT [PK_tCsCierresBackup] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina])
)
ON [PRIMARY]
GO