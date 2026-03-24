CREATE TABLE [dbo].[tCsPadronAhorrosCli] (
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [codusuariounico] [varchar](15) NULL,
  [codusuario] [varchar](15) NULL,
  CONSTRAINT [PK_tCsPadronAhorrrosCli] PRIMARY KEY CLUSTERED ([CodCuenta], [FraccionCta], [Renovado])
)
ON [PRIMARY]
GO