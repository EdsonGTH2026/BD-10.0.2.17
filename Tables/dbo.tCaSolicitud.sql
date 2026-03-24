CREATE TABLE [dbo].[tCaSolicitud] (
  [CodSolicitud] [varchar](15) NOT NULL,
  [CodProducto] [char](3) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodAsesor] [char](15) NULL,
  [FechaSolicitud] [smalldatetime] NULL,
  [TipoCredito] [char](3) NULL,
  [TipoPrestamo] [char](10) NULL,
  [CodPresAnte] [varchar](25) NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [CodFondo] [varchar](2) NULL,
  [CodGrupo] [char](15) NULL,
  [CodUsuario] [char](15) NOT NULL,
  [NumParticip] [smallint] NOT NULL,
  [MontoSolicitado] [money] NULL,
  [MontoAprobado] [money] NULL,
  [FechaAprobacion] [smalldatetime] NULL,
  [MontoDesembolsado] [money] NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [CodTipoPlan] [tinyint] NOT NULL,
  [ConcTecno] [tinyint] NOT NULL,
  [CodTipoCre] [char](2) NULL CONSTRAINT [DF_tCaSolicitud_CodTipoCre] DEFAULT ('M0'),
  [CodTipoOpe] [char](2) NULL,
  [CodTipoPlaz] [char](1) NOT NULL,
  [Plazo] [int] NULL,
  [Cuotas] [int] NOT NULL,
  [VencDiaFijo] [bit] NOT NULL,
  [FechaDiaFijo] [tinyint] NOT NULL,
  [FechaEstado] [smalldatetime] NULL,
  [GraciaCapital] [smallint] NULL CONSTRAINT [DF_tCaSolicitud_GraciaCapital] DEFAULT (0),
  [GraciaInteres] [smallint] NULL CONSTRAINT [DF_tCaSolicitud_GraciaInteres] DEFAULT (0),
  [TipoGarantia] [varchar](5) NOT NULL CONSTRAINT [DF_tCaSolicitud_TipoGarantia] DEFAULT ('IPN'),
  [TipoCambio] [money] NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [FechaProxVen] [smalldatetime] NULL,
  [CodDestino] [varchar](15) NULL,
  [CodEstado] [varchar](10) NULL,
  [CodEstadoAnte] [varchar](10) NULL,
  [Observacion] [varchar](2000) NULL,
  [Secuencia] [int] NULL,
  [TasaInteres] [money] NULL,
  [INTENegMin] [real] NULL CONSTRAINT [DF_tCaSolicitud_INTENegMin] DEFAULT (0),
  [INTENegMax] [real] NULL CONSTRAINT [DF_tCaSolicitud_INTENegMax] DEFAULT (0),
  [EnLineaCred] [bit] NULL,
  [CodLineaCred] [varchar](25) NULL,
  [NroActa] [int] NULL,
  [EsAgricola] [bit] NULL CONSTRAINT [DF_tCaSolicitud_EsAgricola] DEFAULT (0),
  [CodAnterior] [char](27) NOT NULL CONSTRAINT [DF_tCaSolicitud_CodAnterior] DEFAULT (''),
  [PlazoDesembolso] [bit] NULL CONSTRAINT [DF_tCaSolicitud_PlazoDesembolso] DEFAULT (0),
  [EsCarteraIndirecta] [bit] NULL CONSTRAINT [DF_tCaSolicitud_EsCarteraIndirecta] DEFAULT (0),
  [CodCuenta] [varchar](25) NULL,
  [FraccionCta] [varchar](8) NULL,
  [Renovado] [tinyint] NULL,
  [TipoComision] [tinyint] NULL,
  [TipoValorComision] [tinyint] NULL,
  [ValorComision] [money] NULL,
  [TasaInteresFija] [money] NULL CONSTRAINT [DF_tCaSolicitud_TasaInteresFija] DEFAULT (0),
  [TipoComunal] [char](1) NULL,
  [Ciclo] [varchar](25) NULL,
  [CodOficinaFon] [varchar](4) NULL,
  [CodEntidadTipoFon] [varchar](3) NULL,
  [CodEntidadFon] [varchar](3) NULL,
  [NroCuenta] [varchar](30) NULL,
  [CodUsuarioG] [char](15) NULL,
  [AplicaFEGA] [bit] NOT NULL CONSTRAINT [DF_tCaSolicitud_AplicaFEGA] DEFAULT (0),
  CONSTRAINT [PK_tCaSolicitud] PRIMARY KEY CLUSTERED ([CodSolicitud], [CodProducto], [CodOficina])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tCaClDestino] FOREIGN KEY ([CodDestino]) REFERENCES [dbo].[tCaClDestino] ([CodDestino])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tCaClEstados] FOREIGN KEY ([CodEstado]) REFERENCES [dbo].[tCaClEstados] ([CodEstado])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tCaClEstados1] FOREIGN KEY ([CodEstadoAnte]) REFERENCES [dbo].[tCaClEstados] ([CodEstado])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tCAClTipoPlaz] FOREIGN KEY ([CodTipoPlaz]) REFERENCES [dbo].[tCAClTipoPlaz] ([CodTipoPlaz])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tClFondos] FOREIGN KEY ([CodFondo]) REFERENCES [dbo].[tClFondos] ([CodFondo])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tClMonedas] FOREIGN KEY ([CodMoneda]) REFERENCES [dbo].[tClMonedas] ([CodMoneda])
GO

ALTER TABLE [dbo].[tCaSolicitud] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolicitud_tClOficinas] FOREIGN KEY ([CodOficina]) REFERENCES [dbo].[tClOficinas] ([CodOficina])
GO