CREATE TABLE [dbo].[tCsABovDistribucion] (
  [codoficina] [varchar](4) NOT NULL,
  [fechapro] [smalldatetime] NOT NULL,
  [Capital] [money] NULL,
  [Interes] [money] NULL,
  [Moratorio] [money] NULL,
  [CargoxAtraso] [money] NULL,
  [Seguro] [money] NULL,
  [Impuestos] [money] NULL,
  [TotalCA] [money] NULL,
  [garantias] [money] NOT NULL,
  [seguros] [money] NOT NULL,
  [desembolsos] [money] NOT NULL,
  [Ahdepositos] [money] NOT NULL,
  [Ahretiros] [money] NOT NULL,
  [CJ_sobrante] [money] NOT NULL,
  [CJ_faltante] [money] NOT NULL,
  [TOTAL] [money] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsABovDistribucion] TO [marista]
GO