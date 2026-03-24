CREATE TABLE [dbo].[tAhClTipoProducto] (
  [idTipoProd] [smallint] NOT NULL,
  [DescTipoProd] [varchar](150) NULL,
  [Correlativo] [int] NULL CONSTRAINT [DF_tAhClTipoProducto_Correlativo] DEFAULT (0),
  [idEstado] [char](2) NULL CONSTRAINT [DF_tAhClTipoProducto_idEstado] DEFAULT (1),
  [ContaCodigo] [varchar](3) NOT NULL CONSTRAINT [DF_tAhClTipoProducto_ContaCodigo] DEFAULT (''),
  [CuentaContable] [varchar](50) NULL,
  CONSTRAINT [PK_TCLAHTIPOPRODUCTO] PRIMARY KEY CLUSTERED ([idTipoProd])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo para armar la Cuenta Contable', 'SCHEMA', N'dbo', 'TABLE', N'tAhClTipoProducto', 'COLUMN', N'ContaCodigo'
GO