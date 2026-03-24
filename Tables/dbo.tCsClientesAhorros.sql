CREATE TABLE [dbo].[tCsClientesAhorros] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL CONSTRAINT [DF_tCsClientesAhorros_FraccionCta] DEFAULT (0),
  [Renovado] [tinyint] NOT NULL CONSTRAINT [DF_tCsClientesAhorros_Renovado] DEFAULT (0),
  [CodUsCuenta] [varchar](15) NOT NULL,
  [Coordinador] [bit] NULL,
  [Requerido] [bit] NULL,
  [CodRelCuenta] [int] NULL,
  [FechIngreso] [datetime] NULL,
  [FechRetiro] [datetime] NULL,
  [RUC] [varchar](25) NULL,
  [idEstado] [char](2) NULL,
  [Observacion] [varchar](200) NULL,
  CONSTRAINT [PK_tCsClientesAhorros] PRIMARY KEY CLUSTERED ([CodOficina], [CodCuenta], [FraccionCta], [Renovado], [CodUsCuenta])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsClientesAhorros]
  ON [dbo].[tCsClientesAhorros] ([CodUsCuenta])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Oficina', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'CodCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de fraccion', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'FraccionCta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de la cuenta, indica el número de renovaciones', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'Renovado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del Usuario', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'CodUsCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si el usuario o cliente es el coordinador.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'Coordinador'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si el cliente es requerido para todas las transacciones.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'Requerido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Clave de la relación con la cuenta.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'CodRelCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de ingreso o alta a la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'FechIngreso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de retiro o baja de la cuenta.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'FechRetiro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de Ruc del cliente.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'RUC'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del cliente', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'idEstado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Observación del cliente.', 'SCHEMA', N'dbo', 'TABLE', N'tCsClientesAhorros', 'COLUMN', N'Observacion'
GO