CREATE TABLE [dbo].[tPKCliAct] (
  [idPK] [int] NOT NULL CONSTRAINT [DF_tPKCliAct_idPK] DEFAULT (0),
  [CodActDet] [varchar](6) NOT NULL CONSTRAINT [DF_tPKCliAct_CodActDet] DEFAULT (''),
  [IdCliente] [smallint] NOT NULL CONSTRAINT [DF_tPKCliAct_IdCliente] DEFAULT (0),
  [IdProducto] [smallint] NOT NULL CONSTRAINT [DF_tPKCliAct_IdProducto] DEFAULT (0),
  [CodSerie] [char](2) NOT NULL CONSTRAINT [DF_tPKCliAct_CodSerie] DEFAULT (''),
  [Servidor] [varchar](50) NOT NULL CONSTRAINT [DF_tPKCliAct_Servidor] DEFAULT (''),
  [BaseDatos] [varchar](50) NOT NULL CONSTRAINT [DF_tPKCliAct_BaseDatos] DEFAULT (''),
  [FAct] [datetime] NULL,
  [Estado] [varchar](15) NOT NULL CONSTRAINT [DF_tPKCliAct_Estado] DEFAULT ('PENDIENTE'),
  [CodOficinaAfectadas] [varchar](200) NOT NULL CONSTRAINT [DF_tPKCliAct_CodOficinaAfectadas] DEFAULT (''),
  [ResultadoExec] [varchar](4000) NOT NULL CONSTRAINT [DF_tPKCliAct_ResultadoExec] DEFAULT (''),
  CONSTRAINT [PK_tPKCliAct] PRIMARY KEY CLUSTERED ([idPK], [CodActDet])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPKCliAct] WITH NOCHECK
  ADD CONSTRAINT [FK_tPKCliAct_tPKPrj] FOREIGN KEY ([idPK]) REFERENCES [dbo].[tPKAct] ([idPK])
GO

ALTER TABLE [dbo].[tPKCliAct] WITH NOCHECK
  ADD CONSTRAINT [FK_tPKCliAct_tPKPrjDet] FOREIGN KEY ([idPK], [CodActDet]) REFERENCES [dbo].[tPKActDet] ([idPK], [CodActDet])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'identificador de paquete', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'idPK'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de detalle del paquuete', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'CodActDet'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'identificador de cliente', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'IdCliente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'identificador del producto', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'IdProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de serie de la bd', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'CodSerie'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'servidor donde se aplico', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'Servidor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Bd Aplicada', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'BaseDatos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de aplicacion', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'FAct'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del paquete PENDIENTE ACTUALIZADO', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Oficinas Afectadas', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'CodOficinaAfectadas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Mensajes desplegados producto de la aplicacion', 'SCHEMA', N'dbo', 'TABLE', N'tPKCliAct', 'COLUMN', N'ResultadoExec'
GO