CREATE TABLE [dbo].[tCaCodigosParametros] (
  [SiglaSolicitud] [varchar](10) NOT NULL,
  [SecSolicitud] [varchar](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecSolicitud] DEFAULT (0),
  [SecGrupo] [varchar](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecGrupo] DEFAULT (0),
  [idComercial] [int] NULL CONSTRAINT [DF_tCaCodigosParametros_idComercial] DEFAULT (1),
  [idMicroempresa] [int] NULL CONSTRAINT [DF_tCaCodigosParametros_idMicroempresa] DEFAULT (2),
  [idConsumo] [int] NULL CONSTRAINT [DF_tCaCodigosParametros_idConsumo] DEFAULT (3),
  [idHipotecario] [int] NULL CONSTRAINT [DF_tCaCodigosParametros_idHipotecario] DEFAULT (4),
  [idFideicomiso] [int] NULL CONSTRAINT [DF_tCaCodigosParametros_idFideicomiso] DEFAULT (5),
  [SecCodComercial] [numeric](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecCodComercial] DEFAULT (0),
  [SecCodMicroempresa] [numeric](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecCodMicroempresa] DEFAULT (0),
  [SecCodConsumo] [numeric](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecCodConsumo] DEFAULT (0),
  [SecCodHipotecario] [numeric](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecCodHipotecario] DEFAULT (0),
  [SecCodFideicomiso] [numeric] NULL CONSTRAINT [DF_tCaCodigosParametros_SecCodFideicomiso] DEFAULT (0),
  [SecAprobaDesembolso] [numeric](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecAprobaDesembolso] DEFAULT (0),
  [SecTransCaja] [numeric](10) NULL CONSTRAINT [DF_tCaCodigosParametros_SecTransCaja] DEFAULT (0),
  [CodOficina] [varchar](4) NOT NULL,
  [SecRFA] [numeric] NULL,
  [SecBoletas] [numeric] NULL,
  [SecBolOperacion] [numeric] NULL,
  [SecBolCobro] [numeric] NULL,
  [SiglaBoletas] [varchar](10) NULL,
  CONSTRAINT [PK_tCaCodigosParametros] PRIMARY KEY CLUSTERED ([SiglaSolicitud], [CodOficina])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaCodigosParametros] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaCodigosParametros_tClOficinas] FOREIGN KEY ([CodOficina]) REFERENCES [dbo].[tClOficinas] ([CodOficina])
GO