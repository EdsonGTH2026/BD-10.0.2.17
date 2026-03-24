CREATE TABLE [dbo].[tTcBovClMovimientos] (
  [CodMovi] [char](3) NOT NULL,
  [Movimiento] [varchar](20) NULL,
  [EnEntrada] [bit] NOT NULL,
  [EnSalida] [bit] NOT NULL,
  [EnAnadir] [bit] NULL,
  [SeContabiliza] [bit] NOT NULL,
  [ContaCodigoE] [varchar](25) NOT NULL,
  [ContaCodigoS] [varchar](25) NOT NULL
)
ON [PRIMARY]
GO