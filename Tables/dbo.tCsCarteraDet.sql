CREATE TABLE [dbo].[tCsCarteraDet] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [char](19) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodDestino] [varchar](5) NULL,
  [MontoDesembolso] [money] NULL,
  [SaldoCapital] [money] NOT NULL,
  [SaldoInteres] [money] NOT NULL,
  [SaldoMoratorio] [money] NOT NULL,
  [OtrosCargos] [money] NOT NULL,
  [Impuestos] [money] NULL,
  [CargoMora] [money] NULL,
  [UltimoMovimiento] [smalldatetime] NULL,
  [CapitalAtrasado] [money] NOT NULL,
  [CapitalVencido] [money] NOT NULL,
  [SaldoEnMora] [money] NOT NULL,
  [TipoCalificacion] [char](1) NULL,
  [InteresVigente] [money] NULL,
  [InteresVencido] [money] NULL,
  [InteresCtaOrden] [money] NULL,
  [InteresDevengado] [money] NULL,
  [MoratorioVigente] [money] NULL,
  [MoratorioVencido] [money] NULL,
  [MoratorioCtaOrden] [money] NULL,
  [MoratorioDevengado] [money] NULL,
  [SecuenciaCliente] [smallint] NULL,
  [SecuenciaGrupo] [smallint] NULL,
  [PReservaCapital] [money] NULL,
  [SReservaCapital] [money] NULL,
  [PReservaInteres] [money] NULL,
  [SReservaInteres] [money] NULL,
  [IDA] [varchar](3) NULL,
  [IReserva] [varchar](10) NULL,
  CONSTRAINT [PK_tCsCarteraDet] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsCarteraDet_CodPrestamo_Fecha]
  ON [dbo].[tCsCarteraDet] ([CodPrestamo], [Fecha])
  INCLUDE ([InteresDevengado])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [ope_dalvarador]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsCarteraDet] TO [int_mmartinezp]
GO