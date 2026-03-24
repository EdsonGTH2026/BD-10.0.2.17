CREATE TABLE [dbo].[tPKActDet] (
  [idPK] [int] NOT NULL CONSTRAINT [DF_tPKActDet_idPK] DEFAULT (0),
  [CodActDet] [varchar](6) NOT NULL,
  [Archivo] [varchar](200) NOT NULL CONSTRAINT [DF_tPKActDet_Archivo] DEFAULT (''),
  [CodUsr] [varchar](15) NOT NULL CONSTRAINT [DF_tPKActDet_CodUsr] DEFAULT (''),
  CONSTRAINT [PK_tPKPrjDet] PRIMARY KEY CLUSTERED ([idPK], [CodActDet])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tPKActDet] WITH NOCHECK
  ADD CONSTRAINT [FK_tPKPrjDet_tPKPrj] FOREIGN KEY ([idPK]) REFERENCES [dbo].[tPKAct] ([idPK])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'identificador de paquete', 'SCHEMA', N'dbo', 'TABLE', N'tPKActDet', 'COLUMN', N'idPK'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de detalle del paquuete', 'SCHEMA', N'dbo', 'TABLE', N'tPKActDet', 'COLUMN', N'CodActDet'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'nombre del archivo del paquete', 'SCHEMA', N'dbo', 'TABLE', N'tPKActDet', 'COLUMN', N'Archivo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'maquina donde se aplicaron los paquetes', 'SCHEMA', N'dbo', 'TABLE', N'tPKActDet', 'COLUMN', N'CodUsr'
GO