CREATE TABLE [dbo].[tCaProdPerTipoCredito] (
  [CodTipoCredito] [tinyint] NOT NULL,
  [Descripcion] [varchar](50) NOT NULL,
  [Activo] [bit] NOT NULL,
  [SeqProductos] [tinyint] NOT NULL,
  [PrevGenerica] [smallmoney] NULL,
  [PrevGenSobre] [bit] NULL,
  [TipoCalificacion] [bit] NULL,
  [CalOtrasInst] [bit] NULL,
  [CalEjecucion] [bit] NULL,
  [CalCastigados] [bit] NULL,
  [AfectaPagosRet] [bit] NULL,
  [AfectaTodosProd] [bit] NULL,
  [PagoParcial] [bit] NULL,
  [ContaCodigo] [varchar](25) NULL,
  [AutoCalificacion] [varchar](15) NULL,
  [AutoClasificacion] [varchar](15) NULL,
  [EsTipoCreditoUnico] [bit] NULL,
  [MontoMaxTipoCred] [money] NULL,
  [AlineaCalificacion] [bit] NOT NULL,
  [NroDiasSuspenso] [smallint] NOT NULL,
  CONSTRAINT [PK_tCaProdPerTipoCredito] PRIMARY KEY CLUSTERED ([CodTipoCredito])
)
ON [PRIMARY]
GO

GRANT REFERENCES ON [dbo].[tCaProdPerTipoCredito] TO [AppPWClientes]
GO