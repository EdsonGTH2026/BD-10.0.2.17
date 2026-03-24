CREATE TABLE [dbo].[tSHFComportamiento] (
  [ReporteInicio] [smalldatetime] NOT NULL,
  [ReporteFin] [smalldatetime] NOT NULL,
  [Emisor] [varchar](3) NULL,
  [LineaNegocio] [int] NOT NULL,
  [TipoTransaccion] [int] NULL,
  [TipoEnvio] [char](1) NULL,
  [idLineaCredito] [varchar](10) NULL,
  [Originador] [varchar](3) NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [SIInicio] [decimal](18, 4) NULL,
  [Disposiciones] [decimal](16, 4) NULL,
  [PagosProgramado] [int] NOT NULL,
  [MovFecha] [smalldatetime] NOT NULL,
  [NroTrans] [int] NULL,
  [MovTipo] [int] NOT NULL,
  [MovClave] [varchar](3) NOT NULL,
  [MovAplica] [int] NOT NULL,
  [MovMonto] [decimal](16, 4) NULL,
  [MovDenominacion] [decimal](18, 4) NOT NULL,
  [NroDiasAtraso] [int] NULL,
  [NroCuotasPagadas] [smallint] NULL,
  [UltimoPago] [smalldatetime] NULL,
  CONSTRAINT [PK_tSHFComportamiento] PRIMARY KEY CLUSTERED ([ReporteInicio], [ReporteFin], [CodPrestamo], [CodUsuario], [MovFecha], [MovTipo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tSHFComportamiento]
  ON [dbo].[tSHFComportamiento] ([CodPrestamo])
  ON [PRIMARY]
GO