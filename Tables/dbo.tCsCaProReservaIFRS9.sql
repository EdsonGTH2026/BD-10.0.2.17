CREATE TABLE [dbo].[tCsCaProReservaIFRS9] (
  [Fecha] [smalldatetime] NULL,
  [CodUsuario] [varchar](30) NULL,
  [CodPrestamo] [varchar](30) NULL,
  [CodProducto] [int] NULL,
  [TipoCredito] [varchar](30) NULL,
  [TasaIntCorriente] [decimal](10, 5) NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [montoGarantia] [money] NULL,
  [SectorEconomico] [varchar](30) NULL,
  [EtapaCredito] [varchar](30) NULL,
  [IngresoTerceraEtapa] [varchar](30) NULL,
  [MesesTerceraEtapa] [int] NULL,
  [NroDiasRemanentes] [int] NULL,
  [PlazoRemanente] [decimal](10, 5) NULL,
  [Periodo_1] [varchar](30) NULL,
  [Dias_Atraso_1] [int] NULL,
  [ATR_1] [int] NULL,
  [Periodo_2] [varchar](30) NULL,
  [Dias_Atraso_2] [int] NULL,
  [ATR_2] [int] NULL,
  [Periodo_3] [varchar](30) NULL,
  [Dias_Atraso_3] [int] NULL,
  [ATR_3] [int] NULL,
  [Periodo_4] [varchar](30) NULL,
  [Dias_Atraso_4] [int] NULL,
  [ATR_4] [int] NULL,
  [Max_ATR] [int] NULL,
  [PuntajeMaxATR] [int] NULL,
  [PromedioDiasAtraso] [int] NULL,
  [PuntajePromedioAtrasos] [int] NULL,
  [PuntajeTotal] [int] NULL,
  [ProIncumplimiento] [decimal](20, 15) NULL,
  [ExpoIncumplimiento_Saldo] [money] NULL,
  [ExpoIncumplimiento_Ajustado] [money] NULL,
  [ExpoIncumplimiento_Total] [money] NULL,
  [SeveridadPerdida] [decimal](20, 15) NULL,
  [SeveridadPerdida_Ajustado] [decimal](20, 15) NULL,
  [SeveridadPerdida_Total] [decimal](20, 15) NULL,
  [Reserva] [money] NULL,
  [ReservaCompleta] [money] NULL,
  [TCartera] [varchar](30) NULL
)
ON [PRIMARY]
GO

CREATE INDEX [IX_Fecha_Codprestamo]
  ON [dbo].[tCsCaProReservaIFRS9] ([Fecha], [CodPrestamo])
  INCLUDE ([SectorEconomico], [EtapaCredito], [Reserva])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsCaProReservaIFRS9] TO [rie_jalvarezc]
GO