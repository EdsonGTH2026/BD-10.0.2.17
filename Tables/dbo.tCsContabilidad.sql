CREATE TABLE [dbo].[tCsContabilidad] (
  [CodOficina] [varchar](4) NOT NULL CONSTRAINT [DF__tCsContab__CodOf__56FA22CE] DEFAULT (''),
  [Fecha] [datetime] NOT NULL CONSTRAINT [DF__tCsContab__Fecha__5511DA5C] DEFAULT (getdate()),
  [CodCta] [varchar](25) NOT NULL CONSTRAINT [DF__tCsContab__CodCt__5605FE95] DEFAULT (''),
  [CodFondo] [varchar](2) NOT NULL CONSTRAINT [DF__tCsContab__CodFo__57EE4707] DEFAULT (''),
  [DiaDebe] [money] NULL CONSTRAINT [DF__tCsContab__DiaDe__58E26B40] DEFAULT (0),
  [DiaHaber] [money] NULL CONSTRAINT [DF__tCsContab__DiaHa__59D68F79] DEFAULT (0),
  [Saldo] [money] NULL,
  CONSTRAINT [PK_tCsContabilidad] PRIMARY KEY CLUSTERED ([CodOficina], [Fecha], [CodCta], [CodFondo])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de Oficina a la que corresponde la suma de las transacciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsContabilidad', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Fecha a la que corresponde la suma de las transacciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsContabilidad', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de Cuenta Contable a la que corresponde la suma de las transacciones ', 'SCHEMA', N'dbo', 'TABLE', N'tCsContabilidad', 'COLUMN', N'CodCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de Fondo a la que corresponde la suma de las transacciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsContabilidad', 'COLUMN', N'CodFondo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Monto correspondiente a la suma de las transacciones en el DEBE', 'SCHEMA', N'dbo', 'TABLE', N'tCsContabilidad', 'COLUMN', N'DiaDebe'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Monto correspondiente a la suma de las transacciones en el HABER', 'SCHEMA', N'dbo', 'TABLE', N'tCsContabilidad', 'COLUMN', N'DiaHaber'
GO