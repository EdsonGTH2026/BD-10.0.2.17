CREATE TABLE [dbo].[tCsEnviosDelgadoConf] (
  [Invoice] [varchar](9) NOT NULL,
  [Invoice_Prov] [varchar](9) NOT NULL,
  [Datecr] [char](10) NULL,
  [_Time] [char](8) NULL,
  [Status] [char](1) NULL,
  [Notes] [varchar](250) NULL,
  [Id_Receiver] [varchar](20) NULL,
  CONSTRAINT [PK_tCsEnviosDelgadoConf] PRIMARY KEY CLUSTERED ([Invoice], [Invoice_Prov])
)
ON [PRIMARY]
GO