CREATE TABLE [dbo].[DepuraciontcsAhorros] (
  [CodCuenta] [varchar](25) NOT NULL,
  [FechaApertura] [datetime] NOT NULL,
  [FechaVencimiento] [datetime] NULL,
  [FechaInactivacion] [datetime] NULL,
  [SaldoCuenta] [money] NOT NULL,
  [Registros] [int] NOT NULL,
  [UltimoRegistro] [datetime] NOT NULL,
  [IDEstadoCta] [char](2) NOT NULL,
  [CodPrestamo] [varchar](25) NULL,
  [IDEstadoCtaConsulta] [char](2) NOT NULL,
  [FechaDepuracion] [datetime] NOT NULL DEFAULT (getdate()),
  [Renovado] [int] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_DepuraciontcsAhorros] PRIMARY KEY CLUSTERED ([CodCuenta], [Renovado])
)
ON [PRIMARY]
GO