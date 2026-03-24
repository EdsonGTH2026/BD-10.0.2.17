CREATE TABLE [dbo].[NoDepuraciontcSAhorros] (
  [CodCuenta] [varchar](25) NOT NULL,
  [Razon] [varchar](50) NULL,
  [IDEstadoCuenta] [char](2) NULL,
  [Renovado] [int] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_NoDepuraciontcSAhorros] PRIMARY KEY CLUSTERED ([CodCuenta])
)
ON [PRIMARY]
GO