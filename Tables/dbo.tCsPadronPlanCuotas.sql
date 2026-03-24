CREATE TABLE [dbo].[tCsPadronPlanCuotas] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodPrestamo] [char](19) NOT NULL,
  [CodUsuario] [char](25) NOT NULL,
  [NumeroPlan] [tinyint] NOT NULL,
  [SecCuota] [smallint] NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [DiasAtrCuota] [smallint] NOT NULL,
  [FechaInicio] [smalldatetime] NOT NULL,
  [FechaVencimiento] [smalldatetime] NOT NULL,
  [FechaPagoConcepto] [smalldatetime] NULL,
  [SecPago] [int] NOT NULL,
  [EstadoCuota] [varchar](10) NULL,
  [EstadoConcepto] [varchar](10) NOT NULL,
  [MontoCuota] [money] NOT NULL,
  [MontoDevengado] [money] NOT NULL,
  [MontoPagado] [money] NOT NULL,
  [MontoCondonado] [money] NOT NULL,
  CONSTRAINT [PK_tCsPadronPlanCuotasvs2] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodPrestamo], [CodUsuario], [NumeroPlan], [SecCuota], [CodConcepto]) WITH (FILLFACTOR = 75)
)
ON [PRIMARY]
GO

CREATE INDEX [IX_CodPrestamo_NumeroPlan_SecCuota]
  ON [dbo].[tCsPadronPlanCuotas] ([CodPrestamo], [NumeroPlan], [SecCuota])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsPadronPlanCuotas] TO [int_mmartinezp]
GO