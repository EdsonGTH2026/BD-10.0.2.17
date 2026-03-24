CREATE TABLE [dbo].[tCsCartera01] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](50) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [MontoDesembolso] [decimal](19, 4) NULL,
  [SaldoCapital] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoCapital] DEFAULT (0),
  [SaldoINTE] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoInteresCorriente] DEFAULT (0),
  [SaldoINPE] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoINPE] DEFAULT (0),
  [OtrosCargos] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoOtrosCargos] DEFAULT (0),
  [Impuestos] [decimal](19, 4) NULL CONSTRAINT [DF_tCsCartera01_Impuestos] DEFAULT (0),
  [FechaUltimoMovimiento] [datetime] NULL,
  [SaldoEnMora] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoEnMora] DEFAULT (0),
  [SaldoCapitalAtrasado] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoCapitalAtrasado] DEFAULT (0),
  [SaldoCapitalVencido] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoCapitalVencido] DEFAULT (0),
  [TipoCalificacion] [char](1) NULL,
  [SaldoINTEVIG] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoINTEVIG] DEFAULT (0),
  [SaldoINPEVIG] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoINPEVIG] DEFAULT (0),
  [SaldoINTESus] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoINTESus] DEFAULT (0),
  [SaldoINPESus] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoINPESus] DEFAULT (0),
  [SaldoCargoMora] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_SaldoCargoMora] DEFAULT (0),
  [INTEDevDia] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_INTEDevDia] DEFAULT (0),
  [INPEDevDia] [decimal](19, 4) NOT NULL CONSTRAINT [DF_tCsCartera01_INPEDevDia] DEFAULT (0),
  [SecuenciaCliente] [int] NULL,
  [SecuenciaGrupo] [int] NULL,
  [CodDestino] [varchar](5) NULL,
  [CodVerificador] [varchar](15) NULL,
  CONSTRAINT [PK_tCsCartera01] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCartera01_CodPrestamo_CodVerificador]
  ON [dbo].[tCsCartera01] ([CodPrestamo], [CodVerificador])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de proceso', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Prestamo del crédito', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Usuario', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Capital', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoCapital'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo Interes Corriente', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoINTE'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo Interes Moratorio', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoINPE'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo por otros Cargos', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'OtrosCargos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de Ultimo Momivimiento', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'FechaUltimoMovimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo en Mora', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoEnMora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo capital Atrasado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoCapitalAtrasado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo capital Vencido', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoCapitalVencido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de Calificación', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'TipoCalificacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Interes Vigente', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoINTEVIG'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Interes Moratorio Vigente', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoINPEVIG'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Interes en Suspenso', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoINTESus'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Interes Moratorio en Suspenso', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoINPESus'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo por cargos en Mora', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'SaldoCargoMora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Interes Devengado del dia', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'INTEDevDia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Interes Moratorio Devengado del dia', 'SCHEMA', N'dbo', 'TABLE', N'tCsCartera01', 'COLUMN', N'INPEDevDia'
GO