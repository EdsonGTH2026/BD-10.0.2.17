CREATE TABLE [dbo].[tCsReformulacion] (
  [Fecha] [datetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [NumReprog] [smallint] NOT NULL,
  [Calificacion] [char](1) NOT NULL,
  [TipoR] [char](5) NULL,
  [FechaReprog] [datetime] NULL,
  [TasaIntAnt] [money] NULL,
  [TasaInt] [money] NULL,
  [Prevision] [money] NULL,
  [CodTipoPlan] [tinyint] NULL,
  [CodTipoPlaz] [char](1) NULL,
  [PerTipoPlaz] [char](3) NULL,
  [Cuotas] [smallint] NULL,
  [Plazo] [smallint] NULL,
  [VencDiaFijo] [bit] NULL,
  [DiaFijo] [tinyint] NULL,
  [FechaDiaFijo] [datetime] NULL,
  [CodPrestamoN] [varchar](25) NULL,
  [Ejecutado] [bit] NULL,
  [Anulado] [bit] NULL,
  [Pagado] [bit] NULL,
  [MontoCapital] [money] NULL,
  CONSTRAINT [PK_tCsReformulacion] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodPrestamo], [NumReprog], [Calificacion])
)
ON [PRIMARY]
GO