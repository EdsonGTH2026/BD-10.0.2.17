CREATE TABLE [dbo].[tPKAct] (
  [idPK] [int] NOT NULL CONSTRAINT [DF_tPKAct_idPK] DEFAULT (0),
  [IdProducto] [smallint] NOT NULL CONSTRAINT [DF_tPKAct_IdProducto] DEFAULT (0),
  [CodSerie] [char](2) NOT NULL CONSTRAINT [DF_tPKAct_CodSerie] DEFAULT (''),
  [CodAct] [varchar](12) NOT NULL CONSTRAINT [DF_tPKAct_CodAct] DEFAULT (''),
  [Descrip] [varchar](200) NOT NULL CONSTRAINT [DF_tPKAct_Descrip] DEFAULT (''),
  [FGen] [smalldatetime] NULL,
  [Estado] [varchar](15) NOT NULL CONSTRAINT [DF_tPKAct_Estado] DEFAULT ('PENDIENTE'),
  [IdClienteExclusivo] [smallint] NOT NULL CONSTRAINT [DF_tPKAct_IdClienteExclusivo] DEFAULT (0),
  [RespuestaEnviada] [bit] NOT NULL CONSTRAINT [DF_tPKAct_RespuestaEnviada] DEFAULT (0),
  [IdClienteInstancia] [tinyint] NOT NULL CONSTRAINT [DF_tPKAct_IdClienteInstancia] DEFAULT (0),
  [CodModuloFinmas] [char](2) NOT NULL CONSTRAINT [DF_tPKAct_CodModuloFinmas] DEFAULT (''),
  [UltVerMayor] [smallint] NOT NULL CONSTRAINT [DF_tPKAct_UltVerMayor] DEFAULT (0),
  [UltVerMenor] [smallint] NOT NULL CONSTRAINT [DF_tPKAct_UltVerMenor] DEFAULT (0),
  [UltVerRevision] [smallint] NOT NULL CONSTRAINT [DF_tPKAct_UltVerRevision] DEFAULT (0),
  [OrdenAplica] [smallint] NOT NULL CONSTRAINT [DF_tPKAct_OrdenAplica] DEFAULT (0),
  CONSTRAINT [PK_tPKPrj] PRIMARY KEY CLUSTERED ([idPK])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'identificador de paquete', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'idPK'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de producto', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'IdProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de serie', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'CodSerie'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del paquete', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'CodAct'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripcion del paquete', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'Descrip'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de Generacion', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'FGen'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Id del Cliente', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'IdClienteExclusivo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Respuesta Enviada', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'RespuestaEnviada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Instancia del cliente', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'IdClienteInstancia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del Modulo', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'CodModuloFinmas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Version mayor', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'UltVerMayor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Version menor', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'UltVerMenor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Revision', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'UltVerRevision'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Orden de aplicacion', 'SCHEMA', N'dbo', 'TABLE', N'tPKAct', 'COLUMN', N'OrdenAplica'
GO