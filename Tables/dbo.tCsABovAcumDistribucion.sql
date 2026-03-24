CREATE TABLE [dbo].[tCsABovAcumDistribucion] (
  [codoficina] [varchar](4) NOT NULL,
  [fechapro] [smalldatetime] NOT NULL,
  [saldoinisis] [money] NULL,
  [saldofinsis] [money] NULL,
  [Capital] [money] NULL,
  [Interes] [money] NULL,
  [Moratorio] [money] NULL,
  [CargoxAtraso] [money] NULL,
  [Seguro] [money] NULL,
  [Impuestos] [money] NULL,
  [TotalCA] [money] NULL,
  [Capital_Progre] [money] NULL,
  [Interes_Progre] [money] NULL,
  [garantias] [money] NULL,
  [seguros] [money] NULL,
  [desembolsos] [money] NULL,
  [Ahdepositos] [money] NULL,
  [Ahretiros] [money] NULL,
  [CJ_sobrante] [money] NULL,
  [CJ_faltante] [money] NULL,
  [fecharecoleccion] [smalldatetime] NULL,
  [recoleccion] [money] NULL,
  [aclaracionmonto] [money] NULL,
  [TOTAL] [money] NULL,
  [Bov_Reco] [money] NULL,
  [AnexoIni] [money] NULL,
  [AnexoFin] [money] NULL,
  [AnexoMov_Bov] [money] NULL,
  [TOTAL_BOV] [money] NULL,
  [DIFERENCIA] [money] NULL,
  [Capital_Facorp] [money] NULL,
  [Interes_Facorp] [money] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsABovAcumDistribucion] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsABovAcumDistribucion] TO [mchavezs2]
GO