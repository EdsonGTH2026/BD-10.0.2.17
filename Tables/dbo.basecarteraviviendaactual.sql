CREATE TABLE [dbo].[basecarteraviviendaactual] (
  [SALDOTOTAL] [money] NULL,
  [codprestamo] [varchar](50) NULL,
  [PAGODELPERIODO] [money] NULL,
  [EPRC_TOTAL] [money] NULL,
  [estado] [varchar](50) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[basecarteraviviendaactual] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[basecarteraviviendaactual] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[basecarteraviviendaactual] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[basecarteraviviendaactual] TO [rie_blozanob]
GO