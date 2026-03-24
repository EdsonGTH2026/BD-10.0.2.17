CREATE TABLE [dbo].[tTaCuentas] (
  [NroTarjeta] [varchar](20) NOT NULL,
  [NroCuenta] [varchar](20) NULL,
  [NombreCliente] [varchar](200) NULL,
  [CodUsuario] [varchar](15) NULL,
  [FecEmision] [smalldatetime] NULL,
  [FecExpira] [smalldatetime] NULL,
  [FecAtiva] [smalldatetime] NULL,
  [HechoPor] [varchar](20) NULL,
  [Estado] [varchar](4) NULL,
  [EstadoOri] [varchar](15) NULL,
  [Saldo] [decimal](16, 2) NULL,
  [FecUltmvo] [smalldatetime] NULL,
  [FechProceso] [smalldatetime] NULL,
  [NroProceso] [int] NULL CONSTRAINT [DF_tTaCuentas_nroproceso] DEFAULT (1),
  [EstadoCuenta] [tinyint] NULL,
  [CodOficina] [varchar](4) NULL,
  CONSTRAINT [PK_tTaCuentas] PRIMARY KEY CLUSTERED ([NroTarjeta])
)
ON [PRIMARY]
GO